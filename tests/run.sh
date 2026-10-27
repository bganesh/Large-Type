#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p build
test_dir=$(mktemp -d build/tests.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
sed '/^let app = NSApplication.shared/,$d' LargeType.swift > "$test_dir/main.swift"
cat tests/LayoutChecks.swift >> "$test_dir/main.swift"
swiftc -module-cache-path build/module-cache "$test_dir/main.swift" -o "$test_dir/checks"
"$test_dir/checks"
