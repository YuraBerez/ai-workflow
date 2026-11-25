#!/usr/bin/env bash
# SessionStart and Stop hook: remind about the learn-loop skill only when the session
# changed a git ref (a commit, a merge or a new branch). Questions and answers stay quiet.
#
#   learn-reminder.sh start   (SessionStart) records a fingerprint of the git refs
#   learn-reminder.sh stop    (Stop) shows the reminder if the fingerprint changed, then
#                             records the new fingerprint
#
# The fingerprint covers the project repository and each git repository one level below it.
# Input: the hook JSON on stdin (session_id). The hook never blocks (it always exits 0).
set -u

root="${CLAUDE_PROJECT_DIR:-$PWD}"
session="$(jq -r '.session_id // "default"' 2>/dev/null || echo default)"
state="${TMPDIR:-/tmp}/learn-reminder-${session}"

fingerprint() {
  for repo in "$root" "$root"/*/; do
    [[ -e "$repo/.git" ]] && git -C "$repo" for-each-ref --format='%(refname) %(objectname)' 2>/dev/null
  done | shasum | cut -d' ' -f1
}

now="$(fingerprint)"
case "${1:-stop}" in
  start)
    echo "$now" >"$state"
    ;;
  stop)
    before="$(cat "$state" 2>/dev/null || true)"
    echo "$now" >"$state"
    if [[ -n "$before" && "$before" != "$now" ]]; then
      echo '{"systemMessage":"Git refs changed in this session. If the work was large, use the learn-loop skill before you continue. The default action is to discard."}'
    fi
    ;;
esac
exit 0
