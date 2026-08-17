#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
TEST_BIN="${TMPDIR:-/tmp}/psst-parser-tests"

cd "$PROJECT_DIR"
swiftc -swift-version 5 Sources/Psst/Models.swift Tests/ParserSmoke.swift -o "$TEST_BIN"
"$TEST_BIN"
