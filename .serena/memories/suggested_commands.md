# よく使うコマンド（開発者向け）

## 新規アプリ生成
- rails new 実行例（README準拠）
  - `rails new kousu_app -d postgresql -j esbuild -c tailwind -m /path/to/rails_template.rb`
  - `cd kousu_app && bin/rails db:setup && bin/rails s`

## 生成後の基本
- DB操作: `bin/rails db:create db:migrate db:seed`
- サーバ: `bin/rails s`
- コンソール: `bin/rails c`
- テスト（RSpec）: `bin/rspec`
- スキーマ注記（annotate）: `bundle exec annotate`

## Serena MCP（本リポジトリの分析に）
- 設定確認: `get_current_config`
- プロジェクト有効化: `activate_project -> ruby-app`
- 構成走査: `list_dir`（recursive）
- パターン検索: `search_for_pattern`（例: `rails_command|g scaffold|TimeEntry|Pundit|Devise`）
- 収集の検討: `think_about_collected_information`
- メモ書き: `write_memory`（overview/style/commands/checklist など）

## macOSユーティリティ
- Homebrew更新: `brew update && brew upgrade`
- PostgreSQLクライアント（libpq）導入: `brew install libpq && echo 'export PATH="$(brew --prefix libpq)/bin:$PATH"' >> ~/.zshrc`