---
name: export-pr-review
description: GitHub PRのdiffとコメントを1ファイルにエクスポートするスキル。ローカルでPRレビュー内容を確認したいときに使用する。「PRをエクスポートして」「このPRのdiffとコメントをまとめて」「PRレビュー内容をファイルに出力して」などのリクエストで発動。明示的に /export-pr-review でも呼び出し可能。
---

# Export PR Review

GitHub PRのdiff・インラインコメント・レビューサマリー・会話コメントを1つのMarkdownファイルにまとめて出力する。

## 使い方

ユーザーからPR URLを受け取り、以下のスクリプトを実行する。

$()$(
  bash
  bash export-pr.sh ...] <PR_URL >[PR_URL
)$()

$(export-pr.sh) はこの skill ディレクトリ内の同梱スクリプトを使う。

## 出力

- 出力先: $(/tmp/pr-review-YYYYMMDD-HHMMSS.md)（デフォルト）
- 環境変数 $(EXPORT_PR_OUTPUT) でパスを上書き可能

## 出力内容（PR毎）

1. **Overview** - $(gh pr view) の結果（タイトル・状態・作成者等）
2. **Inline Review Comments** - コードの特定行に紐づくコメント
3. **Review Summaries** - LGTM / Request Changes等のレビューサマリー
4. **Conversation Comments** - PRスレッドの会話
5. **Diff** - unified diff形式

## 実行後

スクリプトが出力ファイルのパスを stdout に返すので、そのパスをユーザーに伝える。
必要であればファイルの内容をReadして要約・分析する。

## 注意

- $(gh) CLIが認証済みである必要がある（$(gh auth status) で確認）
- プライベートリポジトリはアクセス権が必要
