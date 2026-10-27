#!/bin/sh
set -eu

cd "$(dirname "$0")"
mkdir -p build
build_dir=$(mktemp -d build/compile.XXXXXX)
trap 'rm -rf "$build_dir"' EXIT

xcrun swiftc -O -framework AppKit \
    -module-cache-path build/module-cache \
    LargeType.swift -o "$build_dir/large-type"
mv -f "$build_dir/large-type" ./large-type
printf 'Built %s/large-type\n' "$PWD"
