#!/bin/bash
# Guards the privilege model documented in docs/ARCHITECTURE.md.
# Fails if the source code starts using APIs that would widen Psst's attack surface
# (subprocesses, scripting, Apple Events, privilege escalation, networking, SMC/IOKit)
# or if the entitlements are anything other than App Sandbox alone.
# Usage: ./Scripts/check-privileges.sh [path/to/Psst.app]
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"
status=0

forbidden=(
  '\bProcess[[:space:]]*\('      '\bNSTask\b'               '\bposix_spawn'
  '(^|[^.[:alnum:]_])(system|popen|execv[pe]?|execl[pe]?|fork)[[:space:]]*\('
  '\bdlopen\b'                   '\bNSAppleScript\b'        '\bNSUserAppleScriptTask\b'
  'osascript'                    '\bNSAppleEventDescriptor\b' '\bAEDeterminePermissionToAutomateTarget\b'
  '\bAuthorization(Create|ExecuteWithPrivileges|CopyRights)\b'
  '\bSMJobBless\b'               '\bSMAppService\b'         '\bSMLoginItemSetEnabled\b'
  '\bURLSession\b'               '\bURLRequest\b'           '\bNWConnection\b'
  '\bNWListener\b'               '\bCFSocket'               '\bCFStream'
  '\bIOServiceOpen\b'            '\bIOConnectCall'          'AppleSMC'
  '^[[:space:]]*import[[:space:]]+(Network|IOKit|ScriptingBridge|ServiceManagement|Security|OSAKit)\b'
  '\bNSWorkspace\b'              '\bFileManager\.default\.homeDirectoryForCurrentUser\b'
)

for pattern in "${forbidden[@]}"; do
  if matches=$(grep -RInE "$pattern" Sources/ 2>/dev/null); then
    echo "API no permitida en Sources/ (patrón: $pattern):" >&2
    echo "$matches" >&2
    status=1
  fi
done

check_entitlements() {
  local label="$1" content="$2"
  local keys
  keys=$(printf '%s' "$content" | grep -o '<key>[^<]*</key>' | sort -u || true)
  if [[ "$keys" != "<key>com.apple.security.app-sandbox</key>" ]]; then
    echo "$label: los entitlements deben ser únicamente com.apple.security.app-sandbox. Encontrado:" >&2
    echo "${keys:-<ninguno>}" >&2
    status=1
  elif ! printf '%s' "$content" | tr -d '[:space:]' | grep -q '<key>com.apple.security.app-sandbox</key><true/>'; then
    echo "$label: com.apple.security.app-sandbox debe valer true." >&2
    status=1
  fi
}

check_entitlements "Resources/Psst.entitlements" "$(cat Resources/Psst.entitlements)"

if [[ $# -ge 1 ]]; then
  APP="$1"
  if ! command -v codesign >/dev/null; then
    echo "codesign no está disponible para inspeccionar $APP" >&2
    exit 1
  fi
  check_entitlements "$APP (firma)" "$(codesign -d --entitlements :- "$APP" 2>/dev/null)"
  if ! codesign -dv "$APP" 2>&1 | grep -q 'flags=.*runtime'; then
    echo "$APP: falta el Hardened Runtime en la firma." >&2
    status=1
  fi
fi

if [[ $status -eq 0 ]]; then
  echo "OK: superficie de privilegios y entitlements verificados"
fi
exit $status
