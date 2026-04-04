#!/bin/bash
# Post-edit hook: быстрая валидация core AI файлов.
# Полный аудит: /skill-audit

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
      FINDINGS="${FINDINGS}\n  CRITICAL: ${LINE_COUNT} строк (лимит для SKILL.md: 500)"
    elif [ "$LINE_COUNT" -gt 300 ]; then
      FINDINGS="${FINDINGS}\n  WARNING: ${LINE_COUNT} строк (рекомендация для SKILL.md: <=300)"
    fi
    ;;
  COMMON.md)
    if [ "$LINE_COUNT" -gt 200 ]; then
      FINDINGS="${FINDINGS}\n  CRITICAL: ${LINE_COUNT} строк (лимит для COMMON.md: 200)"
    elif [ "$LINE_COUNT" -gt 120 ]; then
      FINDINGS="${FINDINGS}\n  WARNING: ${LINE_COUNT} строк (рекомендация для COMMON.md: <=120)"
    fi
    ;;
  CLAUDE.md|AGENTS.md|GEMINI.md)
    if [ "$LINE_COUNT" -gt 120 ]; then
      FINDINGS="${FINDINGS}\n  CRITICAL: ${LINE_COUNT} строк (anchor-файл должен оставаться компактным)"
    elif [ "$LINE_COUNT" -gt 60 ]; then
      FINDINGS="${FINDINGS}\n  WARNING: ${LINE_COUNT} строк (anchor-файл начинает дублировать SSOT)"
    fi
    ;;
  *)
    if [ "$LINE_COUNT" -gt 220 ]; then
      FINDINGS="${FINDINGS}\n  WARNING: ${LINE_COUNT} строк (агентский файл выглядит раздутым)"
    fi
    ;;
esac

# Check 2: Self-Review Protocol (anti-pattern)
if grep -q 'Формат отчёта Self-Review\|Алгоритм Self-Review\|Scorecard Self-Review' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  CRITICAL: Self-Review Protocol - заменить на Post-Check inline"
fi

# Check 3: stale references
if grep -q 'qa_agent\.md\|qa-antipatterns/' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  WARNING: Найдены ссылки на несуществующие QA-артефакты"
fi

if grep -q 'gardener\.md\|Protocol Injection\|Escalation Protocol' "$FILE_PATH" 2>/dev/null; then
  FINDINGS="${FINDINGS}\n  CRITICAL: Найдены ссылки на удалённые или устаревшие process-протоколы"
fi

# Check 4: YAML frontmatter в SKILL.md
if [[ "$FILENAME" == "SKILL.md" ]]; then
  if ! head -1 "$FILE_PATH" | grep -q '^---$'; then
    FINDINGS="${FINDINGS}\n  CRITICAL: Отсутствует YAML frontmatter (---)"
  fi
fi

# Check 5: anchor files should not duplicate COMMON.md
if [[ "$FILENAME" == "CLAUDE.md" || "$FILENAME" == "AGENTS.md" || "$FILENAME" == "GEMINI.md" ]]; then
  if grep -q 'Trust No One\|Production Ready\|Minimal Diff' "$FILE_PATH" 2>/dev/null; then
    FINDINGS="${FINDINGS}\n  WARNING: Anchor-файл дублирует core rules из COMMON.md"
  fi
fi

if [ -n "$FINDINGS" ]; then
  echo -e "skill-lint: ${LABEL}${FINDINGS}" >&2
  echo -e "  Исправь найденные проблемы. Для полного аудита: /skill-audit" >&2
  exit 2
fi

exit 0
