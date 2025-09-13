# プロジェクト概要

- 種別: Railsアプリ“本体”ではなく、Time Tracking（工数管理）アプリを自動生成する Rails Application Template（`rails_template.rb`）と設計ドキュメント（`docs/*`）。
- 目的: `rails new -m rails_template.rb` の一発実行で、認証・組織・プロジェクト/タスク・工数入力・簡易ダッシュボード/一覧・シード入りのMVPを構築する。
- 主な機能（テンプレ適用後に出来上がるアプリ）:
  - 認証: Devise
  - 認可: Pundit（導入のみ、ポリシーは最小）
  - ドメイン: Organization, Membership(role), Project, Task, TimeEntry（承認系フィールド含む）
  - 画面: Dashboard#show を root、TimeEntries一覧に合計表示
  - 初期データ: admin@example.com/password、デモ組織・案件・週次工数
- 技術スタック（テンプレ内で追加・利用）:
  - Ruby on Rails（7系想定）、DB: PostgreSQL、JS: esbuild、CSS: Tailwind（オプション）
  - Gem: devise, pundit, pg, rspec-rails, factory_bot_rails, faker, annotate, dotenv-rails, letter_opener
- 設定: timezone=Tokyo, AR=local、generatorsでhelper/assets抑止、開発のmailer default_url_options 設定。
- リポジトリ構成: `rails_template.rb`, `README.md`, `docs/erd.mmd`, `docs/mvp_backlog.md`, `.serena/*`, `.ruby-lsp/*`。
- 想定フロー: READMEのコマンドで新規アプリを生成→`db:setup`→起動→ログイン→工数入力。