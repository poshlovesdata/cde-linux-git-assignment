#!/usr/bin/env bash
set -euo pipefail


# allow passing target dir as an argument, else default
TARGET_DIR="${1:-$HOME/Documents/cde_linux_git_assignment/test_data}"

# ensure target directory exists
mkdir -p "$TARGET_DIR"

# create dummy files
cd "$TARGET_DIR"
touch test1.csv test2.csv test1.json test2.json ignore.txt

echo "dummy files created in $TARGET_DIR"
ls -1 "$TARGET_DIR"