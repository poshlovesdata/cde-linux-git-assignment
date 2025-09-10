#!/usr/bin/env bash
set -euo pipefail

# purpose: move all csv and json files from a source folder to a destination folder (json_and_csv).

# allow passing source dir as an argument, else default
SOURCE_DIR="${1:-$HOME/Documents/cde_linux_git_assignment/test_data}"
DEST_DIR="${2:-$HOME/Documents/cde_linux_git_assignment/test_data/json_and_csv}"

# ensure destination directory exists
if [ ! -d "$DEST_DIR" ]; then
  echo "destination directory does not exist. creating now."
  mkdir -p "$DEST_DIR"
fi

# track if any file was moved
files_moved=false

# move csv files if they exist
if ls "$SOURCE_DIR"/*.csv >/dev/null 2>&1; then
  echo "moving csv files..."
  mv "$SOURCE_DIR"/*.csv "$DEST_DIR"
  files_moved=true
fi

# move json files if they exist
if ls "$SOURCE_DIR"/*.json >/dev/null 2>&1; then
  echo "moving json files..."
  mv "$SOURCE_DIR"/*.json "$DEST_DIR"
  files_moved=true
fi

# final check
if [ "$files_moved" = true ]; then
  echo "files moved successfully to $DEST_DIR"
  moved_count=$(ls "$DEST_DIR" | wc -l)
  echo "total files in $DEST_DIR: $moved_count"
else
  echo "no csv or json files found in $SOURCE_DIR"
fi
