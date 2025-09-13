# タスク完了チェックリスト

- コード生成/変更の再現性
  - `rails_template.rb` の変更が idempotent に動作するか（同一正規表現で `gsub_file` がヒットするか）。
  - 必要なら正規表現の堅牢化、あるいは Concern/テンプレト override 方式へ移行。
- DB移行
  - `db:migrate` が成功すること、必要な index / FK を追加していること（特に time_entries の複合indexなど）。
  - `db:seed` がエラーなく走ること（初回/再実行）。
- 認可
  - Pundit Policy を追加/更新し、一覧取得は `policy_scope` を通し、`verify_authorized` 等を適用。
- 画面
  - TimeEntries 一覧のN+1が出ていないか（`includes(:project, :task)`など）。
  - 日本語文言/時刻表記/タイムゾーンが正しい。
- テスト
  - `bin/rspec` が緑。最低限のモデル/ポリシー/リクエストSpecを追加。
- ドキュメント
  - README/ERD/バックログの更新反映（新規機能・制約・使い方）。
- 開発者体験
  - `annotate` 実行済み、RuboCop等の導入方針があれば適用。