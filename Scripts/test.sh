#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/psst-tests.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
TEST_BIN="$WORK_DIR/psst-model-tests"

cd "$PROJECT_DIR"
"$SCRIPT_DIR/check-privileges.sh"
swiftc -swift-version 5 Sources/Psst/Models.swift Tests/ModelSmoke.swift -o "$TEST_BIN"
"$TEST_BIN"
