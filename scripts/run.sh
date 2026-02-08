#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: run.sh [OPTIONS]

Analyzes staged git changes and produces a conventional commit message.

Options:
  --type TYPE    Force commit type (feat, fix, refactor, docs, chore, test, style)
  --scope SCOPE  Force scope (overrides auto-detection)
  --verbose      Show reasoning for type/scope decisions
  --quiet        Output only the commit message
  --help         Show this help message
EOF
  exit 0
}

# --- Parse arguments ---
FORCE_TYPE=""
FORCE_SCOPE=""
VERBOSE=false
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help) usage ;;
    --type) FORCE_TYPE="$2"; shift 2 ;;
    --scope) FORCE_SCOPE="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    --quiet) QUIET=true; shift ;;
    *) echo "Error: Unknown option '$1'" >&2; exit 1 ;;
  esac
done

# --- Check for staged changes ---
DIFF=$(git diff --cached --stat 2>/dev/null || true)
if [[ -z "$DIFF" ]]; then
  echo "Error: No staged changes found. Stage files with 'git add' first." >&2
  exit 1
fi

DIFF_CONTENT=$(git diff --cached 2>/dev/null || true)
FILES_CHANGED=$(git diff --cached --name-only 2>/dev/null || true)
FILES_STATUS=$(git diff --cached --name-status 2>/dev/null || true)

# --- Detect scope ---
detect_scope() {
  local dirs
  dirs=$(echo "$FILES_CHANGED" | xargs -I{} dirname {} | sort -u)
  local dir_count
  dir_count=$(echo "$dirs" | wc -l | tr -d ' ')

  if [[ "$dir_count" -eq 1 ]]; then
    local d
    d=$(echo "$dirs" | head -1)
    if [[ "$d" = "." ]]; then
      echo ""
    else
      # Use the first meaningful path component
      echo "$d" | cut -d'/' -f1-2 | sed 's|/|-|g'
    fi
  else
    # Find common parent
    local common
    common=$(echo "$dirs" | head -1 | cut -d'/' -f1)
    local all_share=true
    while IFS= read -r d; do
      if [[ "$(echo "$d" | cut -d'/' -f1)" != "$common" ]]; then
        all_share=false
        break
      fi
    done <<< "$dirs"
    if [[ "$all_share" = true && "$common" != "." ]]; then
      echo "$common"
    else
      echo ""
    fi
  fi
}

# --- Detect type ---
detect_type() {
  local added_files modified_files deleted_files renamed_files
  added_files=$(echo "$FILES_STATUS" | grep -c '^A' || true)
  modified_files=$(echo "$FILES_STATUS" | grep -c '^M' || true)
  deleted_files=$(echo "$FILES_STATUS" | grep -c '^D' || true)
  renamed_files=$(echo "$FILES_STATUS" | grep -c '^R' || true)

  # Check if only doc files
  local non_doc_files
  non_doc_files=$(echo "$FILES_CHANGED" | grep -cvE '\.(md|txt|rst|adoc)$' || true)
  if [[ "$non_doc_files" -eq 0 ]]; then
    echo "docs"
    return
  fi

  # Check if only test files
  local non_test_files
  non_test_files=$(echo "$FILES_CHANGED" | grep -cvE '(test|spec|__tests__)' || true)
  if [[ "$non_test_files" -eq 0 ]]; then
    echo "test"
    return
  fi

  # Check if only config/chore files
  local config_patterns='(package\.json|package-lock\.json|yarn\.lock|\.eslintrc|\.prettierrc|tsconfig|Makefile|Dockerfile|\.github|\.gitignore|\.env\.example)'
  local non_config_files
  non_config_files=$(echo "$FILES_CHANGED" | grep -cvE "$config_patterns" || true)
  if [[ "$non_config_files" -eq 0 ]]; then
    echo "chore"
    return
  fi

  # Check diff content for fix signals
  local fix_signals
  fix_signals=$(echo "$DIFF_CONTENT" | grep -ciE '(fix|correct|patch|resolve|bug|issue|error|crash)' || true)
  if [[ "$fix_signals" -gt 3 ]]; then
    echo "fix"
    return
  fi

  # Renames suggest refactor
  if [[ "$renamed_files" -gt 0 && "$added_files" -eq 0 ]]; then
    echo "refactor"
    return
  fi

  # New files suggest feat
  if [[ "$added_files" -gt 0 ]]; then
    echo "feat"
    return
  fi

  # Check for style-only changes (whitespace, formatting)
  local substantive_changes
  substantive_changes=$(echo "$DIFF_CONTENT" | grep -cE '^\+[^+]' || true)
  local whitespace_changes
  whitespace_changes=$(echo "$DIFF_CONTENT" | grep -cE '^\+\s*$' || true)
  if [[ "$substantive_changes" -gt 0 && "$whitespace_changes" -gt $(( substantive_changes / 2 )) ]]; then
    echo "style"
    return
  fi

  # Default to feat for additions, fix for modifications
  if [[ "$modified_files" -gt "$added_files" ]]; then
    echo "fix"
  else
    echo "feat"
  fi
}

# --- Generate summary ---
generate_summary() {
  local type="$1"
  local file_count
  file_count=$(echo "$FILES_CHANGED" | wc -l | tr -d ' ')

  # Get the first file's basename for single-file commits
  local first_file
  first_file=$(echo "$FILES_CHANGED" | head -1)
  local first_basename
  first_basename=$(basename "$first_file")

  if [[ "$file_count" -eq 1 ]]; then
    local status
    status=$(echo "$FILES_STATUS" | head -1 | cut -f1)
    case "$status" in
      A) echo "add $first_basename" ;;
      D) echo "remove $first_basename" ;;
      M)
        case "$type" in
          fix) echo "fix issue in $first_basename" ;;
          refactor) echo "refactor $first_basename" ;;
          docs) echo "update $first_basename" ;;
          style) echo "format $first_basename" ;;
          *) echo "update $first_basename" ;;
        esac
        ;;
      R*) echo "rename to $first_basename" ;;
      *) echo "update $first_basename" ;;
    esac
  else
    # Multiple files - describe the change broadly
    local scope_hint
    scope_hint=$(echo "$FILES_CHANGED" | head -1 | xargs dirname | cut -d'/' -f1-2)
    case "$type" in
      feat) echo "add new functionality" ;;
      fix) echo "fix issues in ${file_count} files" ;;
      refactor) echo "refactor ${file_count} files" ;;
      docs) echo "update documentation" ;;
      chore) echo "update configuration" ;;
      test) echo "update tests" ;;
      style) echo "format ${file_count} files" ;;
      *) echo "update ${file_count} files" ;;
    esac
  fi
}

# --- Check for breaking changes ---
detect_breaking() {
  if echo "$DIFF_CONTENT" | grep -qiE '(BREAKING|breaking.change|major.change)'; then
    echo "!"
  else
    echo ""
  fi
}

# --- Main ---
TYPE="${FORCE_TYPE:-$(detect_type)}"
SCOPE="${FORCE_SCOPE:-$(detect_scope)}"
BREAKING=$(detect_breaking)
SUMMARY=$(generate_summary "$TYPE")

# Format scope
SCOPE_STR=""
if [[ -n "$SCOPE" ]]; then
  SCOPE_STR="(${SCOPE})"
fi

MESSAGE="${TYPE}${SCOPE_STR}${BREAKING}: ${SUMMARY}"

if [[ "$VERBOSE" = true ]]; then
  echo "Analyzing staged changes..."
  echo "  Files: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/,$//')"
  echo "  Detected type: $TYPE"
  echo "  Detected scope: ${SCOPE:-<none>}"
  echo "  Breaking: ${BREAKING:-no}"
  echo ""
fi

echo "$MESSAGE"
