#!/usr/bin/env bash

set -euo pipefail

shell_under_test=${1:-}
if [[ -z "$shell_under_test" ]]; then
  echo "Usage: $0 <shell>" >&2
  exit 2
fi

if ! command -v "$shell_under_test" >/dev/null; then
  echo "Shell not found: $shell_under_test" >&2
  exit 2
fi

repository_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
extension="$repository_root/gh-copilot-review"
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

mkdir -p \
  "$test_root/bin" \
  "$test_root/inside" \
  "$test_root/inside-other-origin" \
  "$test_root/outside"

cat >"$test_root/bin/gh" <<'EOF'
#!/bin/sh

case "${1:-}" in
  copilot-review)
    shift
    exec "$EXTENSION_UNDER_TEST" "$@"
    ;;
  api)
    if [ "$#" -ne 6 ] ||
      [ -z "${EXPECTED_API_PATH:-}" ] ||
      [ "$2" != "--method" ] ||
      [ "$3" != "POST" ] ||
      [ "$4" != "$EXPECTED_API_PATH" ] ||
      [ "$5" != "-f" ] ||
      [ "$6" != "reviewers[]=copilot-pull-request-reviewer[bot]" ]; then
      echo "Unexpected gh api invocation: $*" >&2
      exit 2
    fi
    exit 1
    ;;
  *)
    echo "Unexpected gh invocation: $*" >&2
    exit 2
    ;;
esac
EOF
chmod +x "$test_root/bin/gh"

git -C "$test_root/inside" -c init.defaultBranch=main init --quiet
git -C "$test_root/inside" remote add origin \
  git@github.com:ChrisCarini/gh-copilot-review.git
git -C "$test_root/inside-other-origin" -c init.defaultBranch=main init --quiet
git -C "$test_root/inside-other-origin" remote add origin \
  git@github.com:example/other-repository.git

run_scenario() {
  local description=$1
  local working_directory=$2
  local input=$3
  local expected_api_path=$4
  local expected_output=$5
  local actual_file="$test_root/actual"
  local expected_file="$test_root/expected"
  local status

  set +e
  (
    cd "$working_directory"
    PATH="$test_root/bin:$PATH" \
      EXTENSION_UNDER_TEST="$extension" \
      EXPECTED_API_PATH="$expected_api_path" \
      DEBUG_COPILOT_REVIEW=false \
      ACTIONS_STEP_DEBUG=false \
      ACTIONS_RUNNER_DEBUG=false \
      RUNNER_DEBUG=0 \
      "$shell_under_test" -c "gh copilot-review \"\$1\"" \
      gh-copilot-review "$input"
  ) >"$actual_file" 2>&1
  status=$?
  set -e

  if [[ $status -ne 1 ]]; then
    echo "FAIL [$shell_under_test] $description: expected status 1, got $status" >&2
    cat "$actual_file" >&2
    return 1
  fi

  printf '%s\n' "$expected_output" >"$expected_file"
  if ! diff -u "$expected_file" "$actual_file"; then
    echo "FAIL [$shell_under_test] $description: unexpected output" >&2
    return 1
  fi

  echo "PASS [$shell_under_test] $description"
}

url=https://github.com/ChrisCarini/gh-copilot-review/pull/123
url_failure=$'🔍 Requesting Copilot Code Review on ChrisCarini/gh-copilot-review PR #123...\n❌ Failure: Could not request Copilot Code Review on https://github.com/ChrisCarini/gh-copilot-review/pull/123'
number_failure=$'🔍 Requesting Copilot Code Review on ChrisCarini/gh-copilot-review PR #123456789...\n❌ Failure: Could not request Copilot Code Review on https://github.com/ChrisCarini/gh-copilot-review/pull/123456789'
outside_number_failure='❌ Error: Could not get git remote URL. Are you in a git repo?'

run_scenario \
  "URL outside a git repository" \
  "$test_root/outside" \
  "$url" \
  "/repos/ChrisCarini/gh-copilot-review/pulls/123/requested_reviewers" \
  "$url_failure"

run_scenario \
  "number outside a git repository" \
  "$test_root/outside" \
  "123456789" \
  "" \
  "$outside_number_failure"

run_scenario \
  "URL inside a git repository with a different origin" \
  "$test_root/inside-other-origin" \
  "$url" \
  "/repos/ChrisCarini/gh-copilot-review/pulls/123/requested_reviewers" \
  "$url_failure"

run_scenario \
  "number inside a git repository with an SSH origin" \
  "$test_root/inside" \
  "123456789" \
  "/repos/ChrisCarini/gh-copilot-review/pulls/123456789/requested_reviewers" \
  "$number_failure"
