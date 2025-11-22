#!/bin/bash

# 使用方法: ./create-pr.sh "Current Problem URL" "Next Problem URL (optional)"
# 例: ./create-pr.sh "https://leetcode.com/problems/two-sum/description/" "https://leetcode.com/problems/add-two-numbers/description/"
# 
# 前提: 既にブランチが作成されており、そのブランチで作業中であること

CURRENT_PROBLEM_URL=$1
NEXT_PROBLEM_URL=$2

if [ -z "$CURRENT_PROBLEM_URL" ]; then
  echo "使用方法: ./create-pr.sh <現在の問題URL> [次の問題URL（省略可）]"
  echo "例: ./create-pr.sh \"https://leetcode.com/problems/two-sum/description/\" \"https://leetcode.com/problems/add-two-numbers/description/\""
  exit 1
fi

# URLから問題名を抽出する関数
extract_problem_name() {
  local url=$1
  # URLから "two-sum" のような部分を抽出
  local slug=$(echo "$url" | sed -n 's|.*/problems/\([^/]*\).*|\1|p')
  # ハイフンをスペースに変換し、各単語の最初の文字を大文字に
  local title=$(echo "$slug" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
  echo "$title"
}

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "❌ エラー: mainブランチから実行しています。"
  echo "問題用のブランチを作成してから実行してください。"
  exit 1
fi

echo "🌿 現在のブランチ: $CURRENT_BRANCH"

# 現在の問題名を抽出
CURRENT_PROBLEM_TITLE=$(extract_problem_name "$CURRENT_PROBLEM_URL")
echo "📝 現在の問題: $CURRENT_PROBLEM_TITLE"

# 次の問題情報
if [ -n "$NEXT_PROBLEM_URL" ]; then
  NEXT_PROBLEM_TITLE=$(extract_problem_name "$NEXT_PROBLEM_URL")
  echo "📝 次の問題: $NEXT_PROBLEM_TITLE"
  NEXT_PROBLEM_LINE="[${NEXT_PROBLEM_TITLE}](${NEXT_PROBLEM_URL})"
else
  NEXT_PROBLEM_LINE="[]()"
fi

echo "📝 PRボディを作成中..."
cat > .github/pull_request_template.md << EOF
## 解く問題
[${CURRENT_PROBLEM_TITLE}](${CURRENT_PROBLEM_URL})
## 次に解く問題
${NEXT_PROBLEM_LINE}
EOF

echo "📤 リモートにプッシュ中..."
git push -u origin "$CURRENT_BRANCH"

echo "🔀 PRを作成中..."
gh pr create \
  --base main \
  --head "$CURRENT_BRANCH" \
  --title "${CURRENT_PROBLEM_TITLE}" \
  --body-file .github/pull_request_template.md

echo "✅ PR作成完了！"
