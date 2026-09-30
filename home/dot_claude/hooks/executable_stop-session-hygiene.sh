#!/usr/bin/env bash

if [ "${stop_hook_active:-}" = "1" ]; then
  exit 0
fi

# Uncommitted files check — output only when dirty
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CHANGES="$(git status --porcelain 2>/dev/null)"
  if [ -n "$CHANGES" ]; then
    FILES="$(printf '%s\n' "$CHANGES" | awk '{print $2}' | tr '\n' ' ' | sed 's/[[:space:]]\+$//')"
    echo "Uncommitted files: $FILES"
  fi
fi

# Scope goal injection — output only when goal file exists and is non-empty
SCOPE_GOAL_FILE="${HOME}/.claude/scope-goal.txt"
if [ -f "$SCOPE_GOAL_FILE" ] && [ -r "$SCOPE_GOAL_FILE" ]; then
  GOAL="$(cat "$SCOPE_GOAL_FILE" 2>/dev/null)"
  if [ -n "$GOAL" ]; then
    echo "Current session goal: $GOAL"
  fi
fi
