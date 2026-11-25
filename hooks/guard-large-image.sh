#!/usr/bin/env bash
# PreToolUse hook (Read): block a Read of an image file that is larger than 300 KB.
#
# A full-size screenshot costs many tokens, and it stays in the context for each later turn.
# Read a small copy instead:
#   sips -Z 600 <image> --out <scratchpad>/<name>.png      (macOS)
#   magick <image> -resize 600x600 <scratchpad>/<name>.png (ImageMagick)
#
# Input: the hook JSON on stdin (tool_name, tool_input.file_path). Exit code 2 blocks the call.
set -u

LIMIT=$((300 * 1024))

input="$(cat)"
[[ "$(jq -r '.tool_name // empty' <<<"$input")" == "Read" ]] || exit 0
path="$(jq -r '.tool_input.file_path // empty' <<<"$input")"
shopt -s nocasematch
[[ "$path" =~ \.(png|jpe?g|gif|webp|heic)$ ]] || exit 0
[[ -f "$path" ]] || exit 0

size=$(stat -f %z "$path" 2>/dev/null || stat -c %s "$path" 2>/dev/null || echo 0)
((size > LIMIT)) || exit 0

echo "Blocked: $path is $((size / 1024)) KB. Read a small copy instead: sips -Z 600 \"$path\" --out <scratchpad>/$(basename "$path")" >&2
exit 2
