#!/usr/bin/env bash
#
# Verify the eight principle bodies are identical across the three auto-loaded
# instruction files. They are intentional copies — each tool needs its own
# file format (CLAUDE.md, a Cursor .mdc rule, and a SKILL.md) — so this guards
# against them silently drifting out of sync.
#
# Usage: scripts/check-sync.sh   (run from anywhere; exits non-zero on drift)
set -euo pipefail
cd "$(dirname "$0")/.."

# Print principles 1-8 from a file: from the "## 1." heading up to (but not
# including) the trailing "---" footer, with trailing blank lines trimmed.
extract() {
  awk '
    /^## 1\. / { p = 1 }
    p && /^---$/ { exit }
    p { buf[++n] = $0 }
    END {
      while (n > 0 && buf[n] ~ /^[[:space:]]*$/) n--
      for (i = 1; i <= n; i++) print buf[i]
    }
  ' "$1"
}

files=(
  "CLAUDE.md"
  ".cursor/rules/hoko-agent-guidelines.mdc"
  "skills/hoko-agent-guidelines/SKILL.md"
)

canonical="$(extract "${files[0]}")"
status=0
for f in "${files[@]:1}"; do
  if ! diff <(printf '%s\n' "$canonical") <(extract "$f") >/dev/null; then
    echo "✗ Principles in $f differ from ${files[0]}:"
    diff <(printf '%s\n' "$canonical") <(extract "$f") || true
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "✓ Principles are in sync across all three instruction files."
fi
exit "$status"
