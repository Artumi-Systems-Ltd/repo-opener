#!/bin/bash

# Check if ~/bin exists, if not create it
if [ ! -d "$HOME/bin" ]; then
  echo "Creating ~/bin directory..."
  mkdir -p "$HOME/bin"
fi

# Define the absolute path to the source and the symlink destination
SRC="$(realpath ./src/repo-opener.sh)"
DEST="$HOME/bin/repo-opener"

# Check if the source file exists
if [ ! -f "$SRC" ]; then
  echo "Error: $SRC does not exist."
  exit 1
fi

# Create a symbolic link in ~/bin using an absolute path
echo "Creating symlink from $SRC to $DEST..."
ln -sf "$SRC" "$DEST"

# Verify the symlink works
if [ -L "$DEST" ]; then
  echo "Installation successful! You can now run 'repo-opener' from anywhere."
else
  echo "Error: Installation failed. Could not create symlink."
  exit 1
fi
