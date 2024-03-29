#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")"

# Run all tests in this directory.
find . -name 'test-*.sh' | sort | while read -r test_script; do
  ./run-test.sh "$test_script"
done
