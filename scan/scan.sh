#!/usr/bin/env bash
# scan.sh — Lia workspace scanner
# Usage: bash scan.sh [/path/to/project]
# Scans a project directory for AI-readiness signals and pastes back to Lia.

set -uo pipefail

TARGET="${1:-.}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

divider() { echo ""; }

echo "╔══════════════════════════════════════════╗"
echo "║          Lia Workspace Scan              ║"
echo "╚══════════════════════════════════════════╝"
echo "Scanning: $TARGET"
echo "Date:     $(date)"

divider
echo "━━━ AI Tooling Detected ━━━"
TOOLS_FOUND=0

check_tool() {
  local path="$1" label="$2"
  if [ -e "$TARGET/$path" ]; then
    echo "  ✓ $label"
    TOOLS_FOUND=$((TOOLS_FOUND + 1))
    return 0
  fi
  return 1
}

check_tool "CLAUDE.md" "CLAUDE.md (agent boot file)"
if check_tool ".claude" ".claude/ (Claude Code config)"; then
  if [ -d "$TARGET/.claude/commands" ]; then
    echo "    └─ commands/: $(ls "$TARGET/.claude/commands" 2>/dev/null | wc -l | tr -d ' ') file(s)"
  fi
  if [ -d "$TARGET/.claude/skills" ]; then
    echo "    └─ skills/: $(ls "$TARGET/.claude/skills" 2>/dev/null | wc -l | tr -d ' ') file(s)"
  fi
fi
if check_tool ".augment" ".augment/ (Augment config)"; then
  if [ -d "$TARGET/.augment/rules" ]; then
    echo "    └─ rules/: $(ls "$TARGET/.augment/rules" 2>/dev/null | wc -l | tr -d ' ') file(s)"
  fi
fi
check_tool ".cursorrules" ".cursorrules (Cursor)"
check_tool ".cursor/rules" ".cursor/rules (Cursor)"
check_tool ".github/copilot-instructions.md" "copilot-instructions.md (GitHub Copilot)"

[ $TOOLS_FOUND -eq 0 ] && echo "  (none detected)"

divider
echo "━━━ Scripts & Automation ━━━"
SCRIPTS_COUNT=0

scan_dir() {
  local dir="$1"
  if [ -d "$TARGET/$dir" ]; then
    local count
    count=$(ls "$TARGET/$dir" 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✓ $dir/ ($count files)"
    ls "$TARGET/$dir" 2>/dev/null | head -12 | sed 's/^/    - /'
    SCRIPTS_COUNT=$((SCRIPTS_COUNT + count))
  fi
}

scan_dir "scripts"
scan_dir "bin"
scan_dir "tools"

if [ -f "$TARGET/Makefile" ]; then
  echo "  ✓ Makefile"
  TARGETS=$(grep -E '^[a-zA-Z0-9_-]+:' "$TARGET/Makefile" 2>/dev/null \
    | sed 's/:.*$//' | head -8 | tr '\n' '  ')
  echo "    targets: $TARGETS"
fi

[ $SCRIPTS_COUNT -eq 0 ] && ! [ -f "$TARGET/Makefile" ] && echo "  (none detected)"

divider
echo "━━━ Tech Stack ━━━"
STACK_FOUND=0

detect_stack() {
  local file="$1" label="$2"
  [ -f "$TARGET/$file" ] && echo "  ✓ $label" && STACK_FOUND=$((STACK_FOUND + 1))
}

detect_stack "package.json"      "Node.js / JavaScript / TypeScript"
detect_stack "Cargo.toml"        "Rust"
detect_stack "go.mod"            "Go"
detect_stack "requirements.txt"  "Python (requirements.txt)"
detect_stack "pyproject.toml"    "Python (pyproject.toml)"
detect_stack "pom.xml"           "Java (Maven)"
detect_stack "build.gradle"      "Java / Kotlin (Gradle)"
detect_stack "mix.exs"           "Elixir"
detect_stack "Gemfile"           "Ruby"
detect_stack "composer.json"     "PHP"

if [ -f "$TARGET/package.json" ] && command -v python3 &>/dev/null; then
  python3 - "$TARGET/package.json" <<'PYEOF' 2>/dev/null || true
import json, sys
try:
  d = json.load(open(sys.argv[1]))
  name = d.get("name", "")
  if name: print(f"    name: {name}")
  scripts = d.get("scripts", {})
  if scripts:
    keys = list(scripts.keys())[:6]
    print(f"    npm scripts: {', '.join(keys)}")
except: pass
PYEOF
fi

[ $STACK_FOUND -eq 0 ] && echo "  (none detected)"

divider
echo "━━━ Git Activity ━━━"
if git -C "$TARGET" rev-parse --git-dir &>/dev/null 2>&1; then
  echo "  Branch:      $(git -C "$TARGET" branch --show-current 2>/dev/null)"
  echo "  Commits:     $(git -C "$TARGET" rev-list --count HEAD 2>/dev/null)"
  echo "  Contributors:$(git -C "$TARGET" log --format='%ae' 2>/dev/null | sort -u | wc -l | tr -d ' ')"
  echo "  Recent commits:"
  git -C "$TARGET" log --oneline -6 2>/dev/null | sed 's/^/    /'
else
  echo "  (no git history)"
fi

divider
echo "━━━ Context & Memory Files ━━━"
CONTEXT=$(find "$TARGET" -maxdepth 4 -name "*.md" 2>/dev/null \
  | grep -iE "(CLAUDE|CONTEXT|MEMORY|SUMMARY|ARCHITECTURE|DECISION|ADR|NOTES|JOURNAL)" \
  | grep -v node_modules | grep -v "/.git/" | sort | head -15)

if [ -n "$CONTEXT" ]; then
  while IFS= read -r f; do
    LINES=$(wc -l < "$f" 2>/dev/null | tr -d ' ')
    REL=$(echo "$f" | sed "s|$TARGET/||")
    echo "  $REL ($LINES lines)"
  done <<< "$CONTEXT"
else
  echo "  (none detected)"
fi

divider
echo "━━━ Summary Signal ━━━"
echo "  AI tooling:    $TOOLS_FOUND indicator(s)"
echo "  Scripts/auto:  $SCRIPTS_COUNT file(s)"
CONTEXT_COUNT=$(echo "$CONTEXT" | grep -c . 2>/dev/null || echo 0)
echo "  Context docs:  $CONTEXT_COUNT file(s)"
echo "  Stack signals: $STACK_FOUND"
divider
echo "━━━ Paste this entire output to Lia ━━━"
