#!/usr/bin/env bash
# export-pr.sh: GitHub PRのdiff + コメントを1ファイルにまとめる
# Usage: export-pr.sh <PR_URL> [PR_URL ...]

set -euo pipefail

OUTPUT_FILE="${EXPORT_PR_OUTPUT:-/tmp/pr-review-$(date +%Y%m%d-%H%M%S).md}"

parse_pr_url() {
  local url="$1"
  # https://github.com/owner/repo/pull/123 形式をパース
  if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    PR_NUM="${BASH_REMATCH[3]}"
  else
    echo "ERROR: URLの形式が不正です: $url" >&2
    return 1
  fi
}

export_pr() {
  local url="$1"
  parse_pr_url "$url"

  local repo="$OWNER/$REPO"

  echo "## PR #$PR_NUM — $repo"
  echo
  echo "> $url"
  echo

  # PR概要
  echo "### Overview"
  echo '```'
  gh pr view "$PR_NUM" --repo "$repo" 2>/dev/null || echo "(PR情報取得失敗)"
  echo '```'
  echo

  # Inline review comments (コード行に紐づく)
  echo "### Inline Review Comments"
  local inline
  inline=$(gh api "repos/$repo/pulls/$PR_NUM/comments" \
    --jq '.[] | "#### \(.path) (line \(.line // .original_line // "?"))\n**[\(.user.login)]** \(.created_at | split("T")[0])\n\n\(.body)\n"' \
    2>/dev/null)
  if [[ -n "$inline" ]]; then
    echo "$inline"
  else
    echo "_なし_"
  fi
  echo

  # Review summaries (LGTM, Request changes等のサマリーコメント)
  echo "### Review Summaries"
  local reviews
  reviews=$(gh api "repos/$repo/pulls/$PR_NUM/reviews" \
    --jq '.[] | select(.body != "") | "#### \(.user.login) [\(.state)] \(.submitted_at | split("T")[0])\n\n\(.body)\n"' \
    2>/dev/null)
  if [[ -n "$reviews" ]]; then
    echo "$reviews"
  else
    echo "_なし_"
  fi
  echo

  # Conversation comments (PRスレッドの会話)
  echo "### Conversation Comments"
  local conv
  conv=$(gh api "repos/$repo/issues/$PR_NUM/comments" \
    --jq '.[] | "#### \(.user.login) \(.created_at | split("T")[0])\n\n\(.body)\n"' \
    2>/dev/null)
  if [[ -n "$conv" ]]; then
    echo "$conv"
  else
    echo "_なし_"
  fi
  echo

  # Diff
  echo "### Diff"
  echo '```diff'
  gh pr diff "$PR_NUM" --repo "$repo" 2>/dev/null || echo "(diff取得失敗)"
  echo '```'
  echo
  echo "---"
  echo
}

# メイン
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <PR_URL> [PR_URL ...]" >&2
  exit 1
fi

{
  echo "# PR Review Export"
  echo
  echo "_Generated: $(date '+%Y-%m-%d %H:%M:%S')_"
  echo
  echo "---"
  echo

  for url in "$@"; do
    export_pr "$url"
  done
} > "$OUTPUT_FILE"

echo "$OUTPUT_FILE"
