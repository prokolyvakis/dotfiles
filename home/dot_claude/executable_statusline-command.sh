#!/usr/bin/env bash
# Claude Code status line
# Inspired by spaceship-prompt: dir + git branch + model + context

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
short_dir=$(basename "$cwd")

model=$(echo "$input" | jq -r '.model.display_name // ""')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build the status line
parts=()

# Directory (cyan)
parts+=("$(printf '\033[0;36m%s\033[0m' "$short_dir")")

# Git branch (yellow), if available
if [ -n "$git_branch" ]; then
  parts+=("$(printf '\033[0;33m(%s)\033[0m' "$git_branch")")
fi

# Model (dim white)
if [ -n "$model" ]; then
  parts+=("$(printf '\033[2m%s\033[0m' "$model")")
fi

# Context usage (green -> yellow -> red based on % used)
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    color='\033[0;31m'  # red
  elif [ "$used_int" -ge 50 ]; then
    color='\033[0;33m'  # yellow
  else
    color='\033[0;32m'  # green
  fi
  parts+=("$(printf "${color}ctx:%d%%\033[0m" "$used_int")")
fi

printf '%s' "${parts[*]}"
