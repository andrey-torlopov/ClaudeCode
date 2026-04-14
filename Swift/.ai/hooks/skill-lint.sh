#!/bin/bash
# Post-edit hook: fast validation of core AI files.
# Full audit: /skill-audit

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Filter: skill files, agent files, core and anchor files
if [[ ! ("$FILE_PATH" == */.ai/skills/*/SKILL.md || "$FILE_PATH" == */.ai/agents/*.md || "$FILE_PATH" == */COMMON.md || "$FILE_PATH" == */CLAUDE.md || "$FILE_PATH" == */AGENTS.md || "$FILE_PATH" == */GEMINI.md) ]]; then
  exit 0
fi

FINDINGS=""
FILENAME=$(basename "$FILE_PATH")
PARENT_DIR=$(basename "$(dirname "$FILE_PATH")")
LABEL="${PARENT_DIR}/${FILENAME}"

# Check 1: Line count
LINE_COUNT=$(wc -l < "$FILE_PATH" | tr -d ' ')
case "$FILENAME" in
  SKILL.md)
    if [ "$LINE_COUNT" -gt 500 ]; then
      FINDINGS="${FINDINGS}\n CRITICAL: ${LINE_COUNT} lines (limit for SKILL.md: 500)"
    elif [ "$LINE_COUNT" -gt 300 ]; then
      FINDINGS="${FINDINGS}\n WARNING: ${LINE_COUNT} lines (recommendation for SKILL.md: <=300)"
    fi
    ;;
  COMMON.md)
    if [ "$LINE_COUNT" -gt 200 ]; then
      FINDINGS="${FINDINGS}\n CRITICAL: ${LINE_COUNT} lines (limit for COMMON.md: 200)"
    elif [ "$LINE_COUNT" -gt 120 ]; then
      FINDINGS="${FINDINGS}\n WARNING: ${LINE_COUNT} lines (recommendation for COMMON.md: <=120)"
    fi
    ;;
  CLAUDE.md|AGENTS.md|GEMINI.md)
    if [ "$LINE_COUNT" -gt 120 ]; then
      FINDINGS="${FINDINGS}\n CRITICAL: ${LINE_COUNT} lines (anchor file must remain compact)"
    elif [ "$LINE_COUNT" -gt 60 ]; then
      FINDINGS="${FINDINGS}\n WARNING: ${LINE_COUNT} lines (the anchor file is starting to duplicate SSOT)"
    fi
    ;;
  *)
    if [ "$LINE_COUNT" -gt 220 ]; then
      FINDINGS="${FINDINGS}\n WARNING: ${LINE_COUNT} lines (agent file looks bloated)"
    fi
    ;;
esac

# Check 2: Self-Review Protocol (anti-pattern)
if grep -q 'Self-Review report format\|Self-Review algorithm\|Scorecard Self-Review' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n CRITICAL: Self-Review Protocol - replace with Post-Check inline"
fi

# Check 3: stale references
if grep -q 'qa_agent\.md\|qa-antipatterns/' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n WARNING: Found references to non-existent QA artifacts"
fi

if grep -q 'gardener\.md\|Protocol Injection\|Escalation Protocol' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n CRITICAL: Found links to deleted or outdated process protocols"
fi

# Check 4: YAML frontmatter in SKILL.md
if [[ "$FILENAME" == "SKILL.md" ]]; then
  if ! head -1 "$FILE_PATH" | grep -q '^---$'; then
    FINDINGS="${FINDINGS}\n CRITICAL: Missing YAML frontmatter (---)"
  fi
fi

# Check 5: anchor files should not duplicate COMMON.md
if [[ "$FILENAME" == "CLAUDE.md" || "$FILENAME" == "AGENTS.md" || "$FILENAME" == "GEMINI.md" ]]; then
  if grep -q 'Trust No One\|Production Ready\|Minimal Diff' "$FILE_PATH" 2>/dev/null; then
    FINDINGS="${FINDINGS}\n WARNING: The Anchor file duplicates the core rules from COMMON.md"
  fi
fi

if [ -n "$FINDINGS" ]; then
  echo -e "skill-lint: ${LABEL}${FINDINGS}" >&2
  echo -e " Fix any problems found. For a full audit: /skill-audit" >&2
  exit 2
fi

exit 0
