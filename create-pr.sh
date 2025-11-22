#!/bin/bash

# 使用方法: ./create-pr.sh "Problem Title" "Problem URL"
# 例: ./create-pr.sh "Two Sum" "https://leetcode.com/problems/two-sum/description/"
# 
# 前提: 既にブランチが作成されており、そのブランチで作業中であること

PROBLEM_TITLE=$1
PROBLEM_URL=$2

if [ -z "$PROBLEM_TITLE" ] || [ -z "$PROBLEM_URL" ]; then
  echo "使用方法: ./create-pr.sh <問題名> <URL>"
  echo "例: ./create-pr.sh \"Two Sum\" \"https://leetcode.com/problems/two-sum/description\""
  exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "❌ エラー: mainブランチから実行しています。"
  echo "問題用のブランチを作成してから実行してください。"
  exit 1
fi

echo "🌿 現在のブランチ: $CURRENT_BRANCH"

# PRテンプレートを更新
echo "📝 PRテンプレートを更新中..."
cat > .github/pull_request_template.md << EOF
## 解く問題
[${PROBLEM_TITLE}](${PROBLEM_URL})
## 次に解く問題
[]()
EOF

git add .github/pull_request_template.md

if git diff --cached --quiet; then
  echo "ℹ️  PRテンプレートに変更がありません。"
else
  echo "💾 変更をコミット中..."
  git commit -m "Update PR template: ${PROBLEM_TITLE}"
fi

echo "📤 リモートにプッシュ中..."
git push -u origin "$CURRENT_BRANCH"

echo "🔀 PRを作成中..."
gh pr create \
  --base main \
  --head "$CURRENT_BRANCH" \
  --title "${PROBLEM_TITLE}" \
  --body-file .github/pull_request_template.md

echo "✅ PR作成完了！"
