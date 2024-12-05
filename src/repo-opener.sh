#!/bin/bash

# Function to find the nearest file or directory up the tree
find_upwards() {
  local target="$1"
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -e "$dir/$target" ]; then
      echo "$dir/$target"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo ""
}

# Function to extract JSON values using jq or grep
get_json_value() {
  local file="$1"
  local key="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r "$key // empty" "$file"
  else
    grep -Po "\"${key##*.}\":\s*\"\K[^\"]*" "$file"
  fi
}

# Check for composer.json
COMPOSER_FILE=$(find_upwards "composer.json")

if [ -n "$COMPOSER_FILE" ]; then
  # Check for .support.source first
  SUPPORT_SOURCE=$(get_json_value "$COMPOSER_FILE" '.support.source')
  if [ -n "$SUPPORT_SOURCE" ]; then
    echo "Opening $SUPPORT_SOURCE from composer.json support.source in your browser..."
    xdg-open "$SUPPORT_SOURCE" >/dev/null
    exit 0
  fi

  # If .support.source not found, check for .name and construct GitHub URL
  NAME=$(get_json_value "$COMPOSER_FILE" '.name')
  if [ -n "$NAME" ]; then
    GITHUB_URL="https://github.com/$NAME"
    echo "Opening $GITHUB_URL from composer.json name in your browser..."
    xdg-open "$GITHUB_URL" >/dev/null
    exit 0
  fi
fi

# Function to find the nearest .git directory
find_git_dir() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.git" ]; then
      echo "$dir/.git"
      return
    fi
    dir=$(dirname "$dir")
  done
  echo ""
}

# Find the nearest .git directory
GIT_DIR=$(find_git_dir)

if [ -z "$GIT_DIR" ]; then
  echo "Error: No Git repository or composer.json source found in this directory or any parent directory."
  exit 1
fi

# Get the remote URL from the nearest .git/config
REMOTE_URL=$(git --git-dir="$GIT_DIR" config --get remote.origin.url)

# Check if the remote URL exists and is a GitHub URL
if [[ -z "$REMOTE_URL" ]]; then
  echo "Error: No remote URL found in the Git repository."
  exit 1
fi

if [[ "$REMOTE_URL" =~ github.com ]]; then
  # Extract the repository URL and convert to HTTPS if necessary
  REPO_URL=$(echo "$REMOTE_URL" | sed -e 's/^git@github.com:/https:\/\/github.com\//' -e 's/.git$//')

  echo "Opening $REPO_URL in your browser..."
  xdg-open "$REPO_URL" >/dev/null
else
  echo "Error: Remote URL is not a GitHub repository."
  exit 1
fi
