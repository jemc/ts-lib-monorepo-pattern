#!/usr/bin/env bash
set -eu
TEST_SCRIPT="$(pwd)/$1"
cd "$(dirname "$0")"
TEST_NAME=$(basename $TEST_SCRIPT .sh)
TEST_DIR="$(pwd)/$TEST_NAME"

# Print an initial message.
echo
echo -e '\033[0;32m' # green
echo "> $TEST_NAME is starting..."
echo -e '\033[0m' # reset color

# Test boilerplate to ensure the monorepo directory is clean & pristine.
git clean ../monorepo -dfX # delete untracked files (build artifacts, etc)
git diff --exit-code ../monorepo # halt if there are uncommitted/unstaged changes
test -z $(git ls-files ../monorepo --exclude-standard --others) # halt if there are untracked files

# Test boilerplate to set up a fresh test directory.
rm -rf "$TEST_DIR"
mkdir "$TEST_DIR"
cd "$TEST_DIR"

# Run the test script.
source "$TEST_SCRIPT"

# Print a success message.
echo
echo -e '\033[0;32m' # green
echo "✔ $TEST_NAME completed successfully!"
echo -e '\033[0m' # reset color
