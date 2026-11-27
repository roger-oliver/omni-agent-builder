#!/usr/bin/env bash
# Behavioral routing test for the Omni orchestrator.
#
# Runs the orchestrator through dry-run requests and checks that it selects
# the right subagents, does not over-delegate simple questions, and plans
# multi-agent work with the documented parallel groups.
#
# The orchestrator and subagents are loaded from the repository this script
# lives in, so run it from a worktree of the revision you want to test.
#
# Usage:
#   bash scripts/test-orchestrator-routing.sh [options]
#
# Options:
#   --agent NAME    Orchestrator agent (default: omni-orchestrator)
#   --model ID      Override the model (provider/model)
#   --timeout SEC   Per-batch timeout (default: 180)
#   --suite N       1 | 2 | 3 | 4 | all (default: all)
#   --keep          Keep the raw model output
#   -h, --help      Show this help
#
# Suites:
#   1  single-agent routing, cases 1-18
#   2  single-agent routing, cases 19-36
#   3  no over-delegation, 4 cases
#   4  multi-agent plans, 4 cases
#
# Requirements: opencode CLI installed and authenticated for the configured
# provider. Cost note: each suite calls the model once and consumes tokens.
#
# Exit codes: 0 all checks passed (skips allowed), 1 failures, 2 usage error.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT="omni-orchestrator"
MODEL=""
BATCH_TIMEOUT=180
SUITE="all"
KEEP=0

usage() {
  sed -n '2,32p' "$0" | sed -E 's/^# ?//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)   AGENT="${2:?--agent needs a value}"; shift 2 ;;
    --model)   MODEL="${2:?--model needs a value}"; shift 2 ;;
    --timeout) BATCH_TIMEOUT="${2:?--timeout needs a value}"; shift 2 ;;
    --suite)   SUITE="${2:?--suite needs a value}"; shift 2 ;;
    --keep)    KEEP=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
case "$SUITE" in
  1|2|3|4|all) ;;
  *) echo "ERROR: --suite must be 1, 2, 3, 4 or all" >&2; exit 2 ;;
esac

command -v opencode >/dev/null 2>&1 || { echo "ERROR: opencode not found in PATH" >&2; exit 1; }
command -v timeout  >/dev/null 2>&1 || { echo "ERROR: timeout not found in PATH" >&2; exit 1; }

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/omni-routing-test.XXXXXX")"
cleanup() {
  if [ "$KEEP" -eq 1 ]; then
    echo "Raw output kept at: $WORKDIR" >&2
  else
    rm -r -- "$WORKDIR" 2>/dev/null || true
  fi
}
trap cleanup EXIT

PASS=0
FAIL=0
SKIP=0

# ---------------------------------------------------------------------------
# Cases
# ---------------------------------------------------------------------------

# request|expected-subagent
SINGLE_CASES=(
  "Capture the business goals, scope, and success metrics for a new dataset export feature.|business-interpreter"
  "Model the actors, use cases, and basic/exception flows for dataset export.|use-case-modeler"
  "Rank the export requirements by business value, risk, and effort.|prioritization-agent"
  "Write the SRS and Given/When/Then acceptance criteria for REQ-020 (dataset export).|requirements-writer"
  "Review the export feature's personal-data handling under GDPR (lawful basis, retention, minimisation).|privacy-compliance-reviewer"
  "Design the high-level architecture and ADRs for a new spike-detection service.|solution-architect"
  "Design the ERD, indexes, and migration strategy for the new subscription tables.|data-schema-modeler"
  "Define the OpenAPI contract for the subscription endpoints.|api-contract-designer"
  "Produce UX flows, wireframes, and WCAG 2.2 AA notes for the subscription management screen.|ui-ux-designer"
  "Implement the Rust endpoint described in ADR-0042.|backend-rust-engineer"
  "Implement the Vue settings page for managing subscriptions.|frontend-vue-engineer"
  "Write an expand/contract migration with a resumable backfill for the new tenant column.|data-migration-engineer"
  "Generate unit tests for the geometry parser.|unit-test-generator"
  "Add integration tests across the API and Postgres tenant filtering.|integration-tester"
  "Write Playwright E2E tests for the export user journey.|e2e-test-engineer"
  "Design a load test for 500 rps against the search endpoint.|load-simulator"
  "Validate that REQ-020 acceptance criteria are met.|qa-validator"
  "Simulate a business user accepting the export workflow.|uat-mimic"
  "Run a WCAG 2.2 AA audit on the new settings page.|accessibility-auditor"
  "Run SAST on the export diff.|sast-scanner"
  "Run DAST against the staging URL.|dast-tester"
  "Audit the new npm dependencies for CVEs and license risk.|dependency-auditor"
  "Validate PR #74 against requirements, ADRs, tests, and traceability.|pr-validator"
  "Open a PR to develop for the export branch.|github-operator"
  "Update the RTM after the merge.|traceability-keeper"
  "Write the API reference documentation for the export endpoints.|technical-writer"
  "Prepare release 0.6.0, bump the version, and draft release notes.|release-manager"
  "Write the rollback plan and health checks for release 0.6.0.|rollback-manager"
  "Add the new test suite to the CI pipeline and promotion gates.|pipeline-engineer"
  "Provision a staging VM and a k3s cluster.|infra-engineer"
  "Bring up the local environment and create a per-iteration test database.|local-env-engineer"
  "Reverse-engineer the legacy Python billing service into As-Is documentation.|legacy-python-analyst"
  "Extract the schema from the legacy SQL Server database (read-only).|schema-extractor"
  "Find where tenant filtering is implemented in this repository.|codebase-explorer"
  "Add structured logging, correlation IDs, and OpenTelemetry tracing to the API.|logging-strategist"
  "Define SLOs, dashboards, and alert rules for the gateway.|alerting-monitor"
)

NO_DELEGATE_CASES=(
  "What is 2+2?"
  "Explain the difference between a PR to develop and a merge to main in Omni."
  "Write a short haiku about databases."
  "What does the abbreviation RTM stand for?"
)

PLAN_CASES=(
  "Set up logging, tracing, and alerting for the new gateway."
  "Review PR #74 for security, dependencies, requirements, and traceability."
  "The export endpoint returns 500 on large files — find the cause, fix it, and validate the fix against the acceptance criteria."
  "Prepare release 0.6.0 and its rollback plan."
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

HEADER_COMMON='ROUTING DRY-RUN — do not call any tools, do not execute anything, do not ask questions.
Assume the product "locateflow" is registered (repos: backend, frontend, decision_logs, ui_design, deploy, www).'

build_single_prompt() {
  local from="$1" to="$2" i=1 idx req
  printf '%s\n' "$HEADER_COMMON"
  printf '%s\n' \
    "For each numbered request, output exactly one line in the form:" \
    "<number>: <subagent-name>" \
    "Use the exact subagent names from your roster. If you would handle it yourself without delegating, write:" \
    "<number>: (orchestrator)" \
    ""
  for ((idx = from; idx < to; idx++)); do
    req="${SINGLE_CASES[$idx]%%|*}"
    printf '%d. %s\n' "$i" "$req"
    i=$((i + 1))
  done
}

build_nodelegate_prompt() {
  local i=1 req
  printf '%s\n' "$HEADER_COMMON"
  printf '%s\n' \
    "For each numbered request, output exactly one line in the form:" \
    "<number>: <subagent-name>" \
    "If you would handle it yourself without delegating, write:" \
    "<number>: (orchestrator)" \
    ""
  for req in "${NO_DELEGATE_CASES[@]}"; do
    printf '%d. %s\n' "$i" "$req"
    i=$((i + 1))
  done
}

build_plan_prompt() {
  local i=1 req
  printf '%s\n' "$HEADER_COMMON"
  printf '%s\n' \
    "For each numbered request, list the exact subagents you would use, in order." \
    "Mark agents that can run in parallel with [parallel: <agent>, <agent>]." \
    "Format: <number>: <agent> -> <agent> [parallel: <agent>]" \
    ""
  for req in "${PLAN_CASES[@]}"; do
    printf '%d. %s\n' "$i" "$req"
    i=$((i + 1))
  done
}

run_batch() {
  local label="$1" prompt="$2" out="$3"
  local -a args=(run --agent "$AGENT")
  [ -n "$MODEL" ] && args+=(--model "$MODEL")

  echo ""
  echo "=== $label ==="
  set +e
  ( cd "$REPO" && timeout "$BATCH_TIMEOUT" opencode "${args[@]}" "$prompt" ) >"$out" 2>&1
  local rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    echo "WARNING: batch exited with code $rc (raw output: $out)" >&2
  fi
  return 0
}

declare -A ACTUAL=()
parse_output() {
  local file="$1" n text
  ACTUAL=()
  while IFS='|' read -r n text; do
    [ -n "$n" ] && ACTUAL["$n"]="$text"
  done < <(
    sed -E 's/\x1b\[[0-9;]*m//g' "$file" \
      | sed -nE 's/^[[:space:]]*[*_-]*[[:space:]]*([0-9]+)[.:)][[:space:]]*(.*)$/\1|\2/p'
  )
}

# Plan answers come in two shapes:
#   1. a fenced summary (`1: agent -> agent ...`), optionally followed by
#      "Notes per line" blocks (`1. ...`) that must not override it;
#   2. numbered Markdown sections whose agents are on the following lines.
# Prefer the fenced summary; otherwise keep the first section per number.
declare -A BLOCKS=()
parse_blocks() {
  local file="$1" line clean match_line n="" cur="" in_fence=0
  local -A fenced=()
  BLOCKS=()

  while IFS= read -r line; do
    clean="$(printf '%s' "$line" | sed -E 's/\x1b\[[0-9;]*m//g')"
    case "$clean" in
      '```'*) in_fence=$((1 - in_fence)); continue ;;
    esac
    match_line="$(printf '%s' "$clean" | sed -E 's/^[[:space:]]*[*_-]+[[:space:]]*//')"
    if [ "$in_fence" -eq 1 ] && [[ "$match_line" =~ ^([0-9]+):[[:space:]]*(.*)$ ]]; then
      fenced["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
  done < "$file"

  if [ "${#fenced[@]}" -gt 0 ]; then
    for n in "${!fenced[@]}"; do
      BLOCKS["$n"]="${fenced[$n]}"
    done
    return
  fi

  while IFS= read -r line; do
    clean="$(printf '%s' "$line" | sed -E 's/\x1b\[[0-9;]*m//g')"
    match_line="$(printf '%s' "$clean" | sed -E 's/^[[:space:]]*[*_-]+[[:space:]]*//')"
    if [[ "$match_line" =~ ^([0-9]+)[.:][[:space:]]*(.*)$ ]]; then
      if [ -n "$n" ] && [ -z "${BLOCKS[$n]+x}" ]; then
        BLOCKS["$n"]="$cur"
      fi
      n="${BASH_REMATCH[1]}"
      cur="${BASH_REMATCH[2]}"
    elif [ -n "$n" ]; then
      cur="$cur"$'\n'"$clean"
    fi
  done < "$file"
  if [ -n "$n" ] && [ -z "${BLOCKS[$n]+x}" ]; then
    BLOCKS["$n"]="$cur"
  fi
}

norm() {
  printf '%s' "$1" \
    | sed -E 's/`//g; s/^[[:space:]]+//; s/[[:space:]]+$//' \
    | tr '[:upper:]' '[:lower:]'
}

has() {
  [[ "$1" == *"$2"* ]]
}

has_parallel() {
  has "$1" "parallel" || has "$1" "concurrent" || has "$1" "independent" || has "$1" "same message"
}

pos() {
  local s="$1" t="$2" pre
  if [[ "$s" != *"$t"* ]]; then
    echo 999999
    return
  fi
  pre="${s%%"$t"*}"
  echo "${#pre}"
}

# Position of the last occurrence (e.g. a final pr-validator verdict after
# the G9 scanners, even when the PR is opened earlier).
pos_last() {
  local s="$1" t="$2" pre
  if [[ "$s" != *"$t"* ]]; then
    echo 999999
    return
  fi
  pre="${s%$t*}"
  echo "${#pre}"
}

agent_available() {
  grep -qxF "$1" <<< "$AGENT_LIST"
}

record() {
  local n="$1" req="$2" expected="$3" got="$4" got_n exp_n
  got_n="$(norm "$got")"
  exp_n="$(norm "$expected")"

  if [ "$exp_n" = "(orchestrator)" ]; then
    if [ "$got_n" = "(orchestrator)" ] || [ "$got_n" = "orchestrator" ]; then
      echo "[PASS] $n. $req -> $got"
      PASS=$((PASS + 1))
    else
      echo "[FAIL] $n. $req -> expected (orchestrator), got: $got"
      FAIL=$((FAIL + 1))
    fi
    return
  fi

  if [ "$got_n" = "$exp_n" ] || [[ "$got_n" == "$exp_n"* ]]; then
    echo "[PASS] $n. $req -> $got"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $n. $req -> expected $expected, got: $got"
    FAIL=$((FAIL + 1))
  fi
}

check_single_suite() {
  local from="$1" to="$2" out="$3" offset="${4:-0}"
  local idx entry expected got i=1 n

  parse_output "$out"
  for ((idx = from; idx < to; idx++)); do
    entry="${SINGLE_CASES[$idx]}"
    expected="${entry##*|}"
    n=$((i + offset))
    got="${ACTUAL[$i]:-<missing>}"

    if ! agent_available "$expected"; then
      echo "[SKIP] $n. ${entry%%|*} -> $expected (agent not in this checkout)"
      SKIP=$((SKIP + 1))
    else
      record "$n" "${entry%%|*}" "$expected" "$got"
    fi
    i=$((i + 1))
  done
}

check_plan_case() {
  local n="$1" req="$2" got="$3" got_n ok=1
  got_n="$(norm "$got")"

  case "$n" in
    1)
      # Alert rules depend on the log/trace schema: logging before alerting.
      has "$got_n" "logging-strategist" || ok=0
      has "$got_n" "alerting-monitor" || ok=0
      [ "$(pos "$got_n" "logging-strategist")" -lt "$(pos "$got_n" "alerting-monitor")" ] || ok=0
      ;;
    2)
      has "$got_n" "sast-scanner" || ok=0
      has "$got_n" "dependency-auditor" || ok=0
      has "$got_n" "pr-validator" || ok=0
      has_parallel "$got_n" || ok=0
      [ "$(pos_last "$got_n" "pr-validator")" -gt "$(pos "$got_n" "sast-scanner")" ] || ok=0
      [ "$(pos_last "$got_n" "pr-validator")" -gt "$(pos "$got_n" "dependency-auditor")" ] || ok=0
      ;;
    3)
      # Explore before build; validate the fix after the build.
      has "$got_n" "codebase-explorer" || ok=0
      has "$got_n" "backend" || ok=0
      has "$got_n" "qa-validator" || ok=0
      has_parallel "$got_n" || ok=0
      [ "$(pos "$got_n" "codebase-explorer")" -lt "$(pos "$got_n" "backend")" ] || ok=0
      [ "$(pos "$got_n" "backend")" -lt "$(pos "$got_n" "qa-validator")" ] || ok=0
      ;;
    4)
      has "$got_n" "release-manager" || ok=0
      has "$got_n" "rollback-manager" || ok=0
      has "$got_n" "pipeline-engineer" || ok=0
      has_parallel "$got_n" || ok=0
      ;;
    *)
      ok=0
      ;;
  esac

  if [ "$ok" -eq 1 ]; then
    echo "[PASS] $n. $req -> $got"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $n. $req -> got: $got"
    FAIL=$((FAIL + 1))
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

echo "Omni orchestrator routing tests"
echo "  repo:  $REPO"
echo "  agent: $AGENT${MODEL:+  model: $MODEL}"
echo "  suite: $SUITE"

AGENT_LIST="$( ( cd "$REPO" && timeout 90 opencode agent list 2>/dev/null ) \
  | sed -E 's/\x1b\[[0-9;]*m//g' \
  | sed -nE 's/^([A-Za-z0-9._-]+) \((primary|subagent|all)\)$/\1/p' || true )"
if [ -z "$AGENT_LIST" ]; then
  echo "ERROR: could not read the agent roster (opencode agent list)" >&2
  exit 1
fi

case "$SUITE" in
  1)
    run_batch "Suite 1: single-agent routing (cases 1-18)" "$(build_single_prompt 0 18)" "$WORKDIR/suite1.out"
    check_single_suite 0 18 "$WORKDIR/suite1.out" 0
    ;;
  2)
    run_batch "Suite 2: single-agent routing (cases 19-36)" "$(build_single_prompt 18 36)" "$WORKDIR/suite2.out"
    check_single_suite 18 36 "$WORKDIR/suite2.out" 18
    ;;
  3)
    run_batch "Suite 3: no over-delegation" "$(build_nodelegate_prompt)" "$WORKDIR/suite3.out"
    parse_output "$WORKDIR/suite3.out"
    i=1
    for req in "${NO_DELEGATE_CASES[@]}"; do
      record "$i" "$req" "(orchestrator)" "${ACTUAL[$i]:-<missing>}"
      i=$((i + 1))
    done
    ;;
  4)
    run_batch "Suite 4: multi-agent plans" "$(build_plan_prompt)" "$WORKDIR/suite4.out"
    parse_blocks "$WORKDIR/suite4.out"
    i=1
    for req in "${PLAN_CASES[@]}"; do
      check_plan_case "$i" "$req" "${BLOCKS[$i]:-<missing>}"
      i=$((i + 1))
    done
    ;;
  all)
    run_batch "Suite 1: single-agent routing (cases 1-18)" "$(build_single_prompt 0 18)" "$WORKDIR/suite1.out"
    check_single_suite 0 18 "$WORKDIR/suite1.out" 0

    run_batch "Suite 2: single-agent routing (cases 19-36)" "$(build_single_prompt 18 36)" "$WORKDIR/suite2.out"
    check_single_suite 18 36 "$WORKDIR/suite2.out" 18

    run_batch "Suite 3: no over-delegation" "$(build_nodelegate_prompt)" "$WORKDIR/suite3.out"
    parse_output "$WORKDIR/suite3.out"
    i=1
    for req in "${NO_DELEGATE_CASES[@]}"; do
      record "$i" "$req" "(orchestrator)" "${ACTUAL[$i]:-<missing>}"
      i=$((i + 1))
    done

    run_batch "Suite 4: multi-agent plans" "$(build_plan_prompt)" "$WORKDIR/suite4.out"
    parse_blocks "$WORKDIR/suite4.out"
    i=1
    for req in "${PLAN_CASES[@]}"; do
      check_plan_case "$i" "$req" "${BLOCKS[$i]:-<missing>}"
      i=$((i + 1))
    done
    ;;
esac

echo ""
echo "Summary: $PASS passed, $FAIL failed, $SKIP skipped"
if [ "$FAIL" -gt 0 ]; then
  echo "Raw model output kept at: $WORKDIR" >&2
  KEEP=1
  exit 1
fi
