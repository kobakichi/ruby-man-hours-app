# コードスタイル/設計方針

- スタイル: Rails標準に準拠（クラス名はCamelCase、ファイル/テーブルはsnake_case）。
- テンプレ適用手法:
  - `rails_command` で scaffold / model / controller 生成。
  - `file` / `insert_into_file` / `inject_into_class` / `gsub_file` で生成直後のコードを上書き/追記。
  - 注意: Railsバージョン差分で`gsub_file`の検索正規表現が不一致になるリスクがあるため、可能ならConcern/テンプレ差し替えでの上書きを検討。
- ドメイン設計: Organization ─ Membership(User, role enum) ─ Project ─ Task ─ TimeEntry（User/Org/Project/Task関連, 承認: approved_at/approved_by_id）。
- バリデーション: TimeEntry.work_date presence、minutes > 0。Project/Task/Organization.name presence。
- タイムゾーン: app=Tokyo, AR=local。
- 一覧スコープ: current_organization や current_user にスコープして取得する方針。
- i18n: 最小（日本語固定テキストあり）。必要なら ja.yml を追加して国際化。
- テスト: rspec-rails 導入のみ（雛形）。FactoryBot/Faker 併用想定。
- セキュリティ/認可: Pundit導入のみ。後続で各 Policy を追加・`verify_authorized` 等の適用を前提。