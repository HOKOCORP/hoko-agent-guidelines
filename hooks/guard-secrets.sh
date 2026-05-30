#!/usr/bin/env bash
#
# Guard Secrets — PreToolUse enforcement hook for Principle #7.
#
# CLAUDE.md states the rule; this hook *enforces* the subset that can be checked
# deterministically. It blocks (exit code 2) before the tool runs:
#   - reading/writing credential files (.env, .credentials.json, keys, ...)
#   - env / printenv secret-fishing
#   - reading credential files via the shell (cat/less/grep/... a secret file)
#   - committing secrets (when gitleaks is installed)
#
# It is a BACKSTOP, not a complete guarantee: hooks fire on tool calls only, so a
# secret the model types directly into its reply cannot be caught here. Keep the
# CLAUDE.md guidance — the two layers cover different gaps.
#
# Wire it via settings.json (see settings.snippet.json).
# Contract: stdin = PreToolUse JSON; exit 2 = block (stderr shown to the agent),
# exit 0 = allow. Requires: jq. Optional: gitleaks (for the commit scan).
set -u

input=$(cat)

# Fail open if we can't parse — guidance in CLAUDE.md still applies, and bricking
# every Read/Bash call on a missing dependency is worse than a soft enforcement gap.
if ! command -v jq >/dev/null 2>&1; then
  echo "guard-secrets: jq not found; enforcement disabled (CLAUDE.md #7 still applies)." >&2
  exit 0
fi

tool=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null) || exit 0
file=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)

deny() { echo "BLOCKED by Guard Secrets (Principle #7): $1" >&2; exit 2; }

# Credential file paths (matched anywhere in the path).
secret_path='(^|/)\.env(\.[A-Za-z0-9_.-]+)?$|(^|/)\.credentials\.json$|(^|/)id_(rsa|dsa|ecdsa|ed25519)$|\.(pem|p12|pfx|key)$|(^|/)\.aws/credentials$|(^|/)\.netrc$|(^|/)\.npmrc$|(^|/)\.pgpass$'
# Tokens that mark a credential file inside a shell command.
secret_token='\.env($|[^A-Za-z0-9_.])|\.env\.|\.credentials\.json|id_(rsa|dsa|ecdsa|ed25519)|\.aws/credentials|\.netrc|\.pgpass|\.(pem|p12|pfx)($|[^A-Za-z0-9_])'
# Commands whose job is to read/print file contents.
read_cmds='cat|bat|less|more|head|tail|nl|xxd|od|hexdump|base64|strings|grep|egrep|rg|awk|sed|cp|scp|rsync'

case "$tool" in
  Read|Edit|MultiEdit|Write)
    if [[ -n "$file" ]] && printf '%s' "$file" | grep -Eq "$secret_path"; then
      deny "accessing credential file '$file'. Reference it by name; don't open it."
    fi
    ;;
  Bash)
    # printenv, or bare/piped/redirected env (allows `env VAR=val cmd`).
    if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])printenv([[:space:]]|$)' \
       || printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])env[[:space:]]*($|\||>)'; then
      deny "'$cmd' fishes for secrets via env/printenv. Test one variable's presence instead (e.g. test -n \"\$TOKEN\")."
    fi
    # A read-style command pointed at a credential file.
    if printf '%s' "$cmd" | grep -Eq "(^|[;&|[:space:]])(${read_cmds})[[:space:]][^;&|]*(${secret_token})"; then
      deny "command reads a credential file. Don't print secret contents."
    fi
    # Commit-time secret scan (best effort; only if gitleaks is present).
    if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+commit' && command -v gitleaks >/dev/null 2>&1; then
      if ! gitleaks protect --staged --no-banner >/dev/null 2>&1; then
        deny "gitleaks detected secrets in the staged changes. Remove them before committing."
      fi
    fi
    ;;
esac

exit 0
