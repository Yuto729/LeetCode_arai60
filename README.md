# LeetCode_arai60
平均1日1問以上目安.

## PR作成の流れ

### 1. ブランチを作成して問題を解く
```bash
git checkout -b problem-123

# 問題を解く（コードを書く）
# ...

git add .
git commit -m "Solve problem 123"
```

### 2. PR作成スクリプトを実行
```bash
./create-pr.sh "現在の問題URL" ["次の問題URL（省略可）"]
```

**例:**
```bash
# URLのみ指定（問題名は自動抽出される）
./create-pr.sh "https://leetcode.com/problems/two-sum/description/"

# 次に解く問題も指定
./create-pr.sh "https://leetcode.com/problems/two-sum/description/" "https://leetcode.com/problems/add-two-numbers/description/"
```

**自動で行われること:**
- URLから問題名を自動抽出（ハイフン→スペース、各単語の先頭を大文字化）
  - 例: `two-sum` → `Two Sum`
- PRテンプレートに問題名とURLを記入
- 次に解く問題があれば、それも記入
- 変更をコミット＆プッシュ
- GitHub CLIでPRを作成

### 3. 自動でDiscord通知用メッセージがPRコメントに投稿される

PRが作成されると、GitHub Actionsが自動でPRのコメント欄に以下のようなメッセージを投稿します：

```
お疲れ様です。

Two Sumに取り組みました。
お手隙の際にレビューをお願いいたします。

問題: https://leetcode.com/problems/two-sum/description/
PR: https://github.com/username/repo/pull/123
言語: Python3
```

## セットアップ（初回のみ）

### 1. GitHub CLIのインストール
```bash
# Ubuntu/Debian
sudo apt install gh

# 認証
gh auth login
```

### 2. スクリプトに実行権限を付与
```bash
chmod +x create-pr.sh
```