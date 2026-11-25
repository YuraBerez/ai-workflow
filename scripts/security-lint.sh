#!/usr/bin/env bash
# Security checks for this repository. CI runs it on each push and PR.
#
#   scripts/security-lint.sh
#
# Checks:
#   1. shellcheck  — shell scripts in hooks/ and scripts/
#   2. gitleaks    — secrets in the files and in the git history
#   3. actionlint  — syntax and expressions of GitHub Actions workflows
#   4. zizmor      — security problems of GitHub Actions workflows, for example
#                    template injection, too many permissions, and credentials
#                    that persist after checkout
#
# On a local machine, the script skips a tool that is not installed and shows a warning.
# In CI (CI=true), a tool that is not installed is an error.
# Exit code 1 if a check fails.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

GITLEAKS_IMAGE="zricethezav/gitleaks:v8.21.2"
failed=0

missing() {
  if [[ "${CI:-}" == "true" ]]; then
    echo "ERROR: $1 is not installed." >&2
    failed=1
  else
    echo "WARNING: $1 is not installed. Skip." >&2
  fi
}

run() {
  local name="$1"
  shift
  echo "== $name"
  if "$@"; then
    echo "OK: $name"
  else
    echo "FAIL: $name" >&2
    failed=1
  fi
}

# The files that git tracks, and new files that git does not ignore.
list() { git ls-files --cached --others --exclude-standard "$@"; }

shell_files=()
while IFS= read -r f; do shell_files+=("$f"); done < <(list 'hooks/*.sh' 'scripts/*.sh')
workflows=()
while IFS= read -r f; do workflows+=("$f"); done < <(list '.github/workflows/*.yml' \
  '.github/workflows/*.yaml' 'templates/.github/workflows/*.yml' 'templates/.github/workflows/*.yaml')

if ((${#shell_files[@]})) && command -v shellcheck >/dev/null; then
  run shellcheck shellcheck "${shell_files[@]}"
else
  missing shellcheck
fi

if command -v gitleaks >/dev/null; then
  run gitleaks gitleaks git --redact --no-banner .
elif command -v docker >/dev/null && docker info >/dev/null 2>&1; then
  run gitleaks docker run --rm -v "$PWD:/repo" -w /repo "$GITLEAKS_IMAGE" git --redact --no-banner /repo
else
  missing gitleaks
fi

if ((${#workflows[@]})); then
  if command -v actionlint >/dev/null; then
    run actionlint actionlint "${workflows[@]}"
  else
    missing actionlint
  fi
  if command -v zizmor >/dev/null; then
    run zizmor zizmor --offline "${workflows[@]}"
  else
    missing zizmor
  fi
fi

exit "$failed"
