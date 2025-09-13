# frozen_string_literal: true

# 工数管理アプリ用 Rails Application Template
# 使い方: rails new kousu_app -d postgresql -j esbuild -c tailwind -m rails_template.rb

def say_step(msg)
  say "\n=== #{msg} ===\n", :green
end

say_step 'Gem を追加します'

gem 'devise'
gem 'pundit'
# pg はrails new -d postgresqlで既に追加されるため二重追加を避ける
if File.exist?('Gemfile') && File.read('Gemfile') !~ /\bgem ["']pg["']/
  gem 'pg'
end

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'annotate'
end

gem_group :development do
  gem 'letter_opener'
  gem 'dotenv-rails'
end

after_bundle do
  say_step '初期設定とジェネレータ'

  rails_command 'g rspec:install'
  rails_command 'g devise:install'
  rails_command 'g pundit:install'

  # Devise User
  rails_command 'g devise User first_name:string last_name:string'

  # ドメイン: 組織/メンバーシップ/プロジェクト/タスク/工数
  rails_command 'g scaffold Organization name:string'
  rails_command 'g scaffold Project organization:references name:string client_name:string billable:boolean budget_hours:integer start_date:date end_date:date'
  rails_command 'g scaffold Task project:references name:string billable:boolean'
  rails_command 'g scaffold TimeEntry organization:references user:references project:references task:references work_date:date minutes:integer note:text billable:boolean approved_at:datetime approved_by_id:integer'
  rails_command 'g model Membership organization:references user:references role:integer'

  say_step 'ApplicationController, モデル関連付け、バリデーションを設定'

  # ApplicationController: 認証と組織スコープ
  file 'app/controllers/application_controller.rb', <<~RUBY
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      before_action :authenticate_user!
      before_action :set_current_organization

      helper_method :current_organization

      private

      def set_current_organization
        return unless current_user
        @current_organization = current_user.organizations.first || Organization.first
      end

      def current_organization
        @current_organization
      end
    end
  RUBY

  # Dashboard
  rails_command 'g controller Dashboard show'
  route "root to: 'dashboard#show'"
  file 'app/views/dashboard/show.html.erb', <<~ERB
    <div class="prose">
      <h1>ダッシュボード</h1>
      <p>ようこそ、<%= current_user&.first_name || current_user&.email %> さん。</p>
      <ul>
        <li><%= link_to '工数入力', time_entries_path %></li>
        <li><%= link_to 'プロジェクト', projects_path %></li>
        <li><%= link_to 'タスク', tasks_path %></li>
      </ul>
    </div>
  ERB

  # モデル: 関連とバリデーション
  file 'app/models/organization.rb', <<~RUBY
    class Organization < ApplicationRecord
      has_many :memberships, dependent: :destroy
      has_many :users, through: :memberships
      has_many :projects, dependent: :destroy
      has_many :time_entries, dependent: :destroy
      validates :name, presence: true
    end
  RUBY

  file 'app/models/membership.rb', <<~RUBY
    class Membership < ApplicationRecord
      belongs_to :organization
      belongs_to :user
      enum :role, { member: 0, manager: 1, admin: 2 }
      validates :role, presence: true
    end
  RUBY

  insert_into_file 'app/models/user.rb', before: /^end\n\z/ do
    <<~'RUBY'

      has_many :memberships, dependent: :destroy
      has_many :organizations, through: :memberships
      has_many :time_entries, dependent: :destroy
    RUBY
  end

  file 'app/models/project.rb', <<~RUBY
    class Project < ApplicationRecord
      belongs_to :organization
      has_many :tasks, dependent: :destroy
      has_many :time_entries, dependent: :nullify
      validates :name, presence: true
    end
  RUBY

  file 'app/models/task.rb', <<~RUBY
    class Task < ApplicationRecord
      belongs_to :project
      has_one :organization, through: :project
      has_many :time_entries, dependent: :nullify
      validates :name, presence: true
    end
  RUBY

  file 'app/models/time_entry.rb', <<~RUBY
    class TimeEntry < ApplicationRecord
      belongs_to :organization
      belongs_to :user
      belongs_to :project
      belongs_to :task, optional: true
      belongs_to :approved_by, class_name: 'User', optional: true

      validates :work_date, presence: true
      validates :minutes, numericality: { only_integer: true, greater_than: 0 }

      scope :between, ->(from, to) { where(work_date: from..to) }

      def hours
        (minutes.to_f / 60.0).round(2)
      end
    end
  RUBY

  say_step 'コントローラ微調整（スコープ）'
  # index取得をpolicy_scopeに置換（存在するパターンを順次置換）
  gsub_file 'app/controllers/projects_controller.rb', /Project\.all/, 'policy_scope(Project)'
  gsub_file 'app/controllers/projects_controller.rb', /current_organization\.projects/, 'policy_scope(Project)'
  gsub_file 'app/controllers/tasks_controller.rb', /Task\.all/, 'policy_scope(Task)'
  gsub_file 'app/controllers/tasks_controller.rb', /Task\.joins\(:project\)\.where\(projects: \{ organization_id: current_organization.id \} \)/, 'policy_scope(Task)'
  gsub_file 'app/controllers/time_entries_controller.rb', /TimeEntry\.all/, 'policy_scope(TimeEntry).includes(:project, :task)'
  gsub_file 'app/controllers/time_entries_controller.rb', /current_organization\.time_entries\.where\(user: current_user\)/, 'policy_scope(TimeEntry).includes(:project, :task)'

  # Strong Parameters: organization/userの自動付与
  inject_into_class 'app/controllers/time_entries_controller.rb', 'TimeEntriesController', <<~'RUBY'
      private
      def time_entry_params
        params.require(:time_entry).permit(:project_id, :task_id, :work_date, :minutes, :note, :billable)
      end

      def set_time_entry_defaults(entry)
        entry.organization ||= current_organization
        entry.user ||= current_user
      end
  RUBY

  gsub_file 'app/controllers/time_entries_controller.rb', /def create.*?end/m, <<~'RUBY'
      def create
        @time_entry = TimeEntry.new(time_entry_params)
        set_time_entry_defaults(@time_entry)
        authorize @time_entry
        if @time_entry.save
          redirect_to time_entries_url, notice: 'Time entry was successfully created.'
        else
          render :new, status: :unprocessable_entity
        end
      end
  RUBY

  gsub_file 'app/controllers/time_entries_controller.rb', /def update.*?end/m, <<~'RUBY'
      def update
        authorize @time_entry
        if @time_entry.update(time_entry_params)
          set_time_entry_defaults(@time_entry)
          redirect_to time_entries_url, notice: 'Time entry was successfully updated.'
        else
          render :edit, status: :unprocessable_entity
        end
      end
  RUBY

  # Pundit Policyの雛形
  say_step 'Pundit Policyを作成'
  file 'app/policies/application_policy.rb', <<~'RUBY'
    class ApplicationPolicy
      attr_reader :user, :record

      def initialize(user, record)
        @user = user
        @record = record
      end

      def index?; false; end
      def show?; false; end
      def create?; false; end
      def new?; create?; end
      def update?; false; end
      def edit?; update?; end
      def destroy?; false; end

      class Scope
        attr_reader :user, :scope
        def initialize(user, scope)
          @user = user
          @scope = scope
        end
        def resolve
          scope.all
        end
      end
    end
  RUBY

  file 'app/policies/project_policy.rb', <<~'RUBY'
    class ProjectPolicy < ApplicationPolicy
      def index?; true; end
      def show?; member?(record.organization); end
      def create?; manager_or_admin?(record.organization); end
      def update?; manager_or_admin?(record.organization); end
      def destroy?; manager_or_admin?(record.organization); end

      class Scope < Scope
        def resolve
          org_ids = user.organizations.select(:id)
          scope.where(organization_id: org_ids)
        end
      end

      private
      def member?(org)
        user.memberships.exists?(organization_id: org.id)
      end
      def manager_or_admin?(org)
        role = user.memberships.find_by(organization_id: org.id)&.role
        %w[manager admin].include?(role)
      end
    end
  RUBY

  file 'app/policies/task_policy.rb', <<~'RUBY'
    class TaskPolicy < ApplicationPolicy
      def index?; true; end
      def show?; member?(record.project.organization); end
      def create?; manager_or_admin?(record.project.organization); end
      def update?; manager_or_admin?(record.project.organization); end
      def destroy?; manager_or_admin?(record.project.organization); end

      class Scope < Scope
        def resolve
          org_ids = user.organizations.select(:id)
          scope.joins(:project).where(projects: { organization_id: org_ids })
        end
      end

      private
      def member?(org)
        user.memberships.exists?(organization_id: org.id)
      end
      def manager_or_admin?(org)
        role = user.memberships.find_by(organization_id: org.id)&.role
        %w[manager admin].include?(role)
      end
    end
  RUBY

  file 'app/policies/time_entry_policy.rb', <<~'RUBY'
    class TimeEntryPolicy < ApplicationPolicy
      def index?; true; end
      def show?; owner? || manager_or_admin?(record.organization); end
      def create?
        return user.present? if record.is_a?(Class)
        owner? || manager_or_admin?(record.organization)
      end
      def update?; owner? || manager_or_admin?(record.organization); end
      def destroy?; manager_or_admin?(record.organization); end

      class Scope < Scope
        def resolve
          org_ids = user.organizations.select(:id)
          # 管理者/マネージャーは所属組織内を全件、メンバーは自分の工数のみ
          if user.memberships.where(organization_id: org_ids, role: %i[manager admin]).exists?
            scope.where(organization_id: org_ids)
          else
            scope.where(organization_id: org_ids, user_id: user.id)
          end
        end
      end

      private
      def owner?
        record.respond_to?(:user_id) && record.user_id == user.id
      end
      def manager_or_admin?(org)
        return false unless org
        role = user.memberships.find_by(organization_id: org.id)&.role
        %w[manager admin].include?(role)
      end
    end
  RUBY

  # TimeEntriesController に簡易のauthorizeフックを追加
  inject_into_class 'app/controllers/time_entries_controller.rb', 'TimeEntriesController', <<~'RUBY'
      before_action :authorize_time_entry, except: [:index]

      private
      def authorize_time_entry
        if defined?(@time_entry) && @time_entry.present?
          authorize @time_entry
        else
          authorize TimeEntry
        end
      end
  RUBY

  say_step 'ビュー簡易調整（工数一覧を週次っぽく）'
  file 'app/views/time_entries/index.html.erb', <<~ERB
    <div class="prose">
      <h1>工数一覧（自分）</h1>
      <p>
        <%= link_to '新規工数', new_time_entry_path, class: 'btn' %>
        <%= link_to 'プロジェクト', projects_path, class: 'btn' %>
      </p>
      <table>
        <thead>
          <tr>
            <th>日付</th>
            <th>プロジェクト</th>
            <th>タスク</th>
            <th>時間(h)</th>
            <th>メモ</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <% total = 0 %>
          <% @time_entries.order(work_date: :desc).each do |e| %>
            <% total += e.hours %>
            <tr>
              <td><%= e.work_date %></td>
              <td><%= e.project&.name %></td>
              <td><%= e.task&.name %></td>
              <td><%= e.hours %></td>
              <td><%= e.note %></td>
              <td>
                <%= link_to '表示', e %>
                <%= link_to '編集', edit_time_entry_path(e) %>
                <%= link_to '削除', e, method: :delete, data: { confirm: '削除しますか?' } %>
              </td>
            </tr>
          <% end %>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="3">合計</th>
            <th><%= total %> h</th>
            <th colspan="2"></th>
          </tr>
        </tfoot>
      </table>
    </div>
  ERB

  say_step 'Seeder を作成'
  file 'db/seeds.rb', <<~RUBY
    # 初期データ
    org = Organization.find_or_create_by!(name: 'デモ組織')

    unless User.exists?(email: 'admin@example.com')
      user = User.create!(email: 'admin@example.com', password: 'password', first_name: 'Admin', last_name: 'User')
      Membership.create!(organization: org, user: user, role: :admin)
    end

    user = User.find_by!(email: 'admin@example.com')

    pj1 = org.projects.find_or_create_by!(name: 'サンプル案件A', client_name: 'Acme', billable: true, budget_hours: 100)
    pj2 = org.projects.find_or_create_by!(name: '社内改善', client_name: 'Internal', billable: false, budget_hours: 50)

    t1 = pj1.tasks.find_or_create_by!(name: '設計', billable: true)
    t2 = pj1.tasks.find_or_create_by!(name: '実装', billable: true)
    t3 = pj2.tasks.find_or_create_by!(name: '資料作成', billable: false)

    start = Date.today.beginning_of_week(:monday)
    (0..4).each do |i|
      date = start + i.days
      TimeEntry.find_or_create_by!(organization: org, user: user, project: pj1, task: t2, work_date: date, minutes: 60 * (i + 1)) do |e|
        e.note = 'サンプル投入'
        e.billable = true
      end
    end
  RUBY

  say_step 'Route/Devise設定 など微調整'
  environment <<~RUBY
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
  RUBY

  application <<~RUBY
    config.generators do |g|
      g.helper false
      g.assets false
    end
  RUBY

  # Devise デフォルトURL（開発）
  insert_into_file 'config/environments/development.rb', after: "config.action_mailer.raise_delivery_errors = false\n" do
    <<~'RUBY'
      config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    RUBY
  end

  # i18n（日本語）/ CSV 利用 / 画面フィルタとCSV出力
  say_step 'i18n/CSV/ビュー調整を適用'
  application <<~RUBY
    config.i18n.available_locales = [:en, :ja]
    config.i18n.default_locale = :ja
  RUBY

  # CSVを利用するための標準ライブラリを読み込み
  file 'config/initializers/require_csv.rb', "require 'csv'\n"

  # ApplicationController を上書き（役割ヘルパ/認可検証/エラーハンドリング付き）
  file 'app/controllers/application_controller.rb', <<~RUBY
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      before_action :authenticate_user!
      before_action :set_current_organization
      after_action :verify_authorized, except: :index, unless: :skip_pundit?
      after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      helper_method :current_organization, :manager_or_admin?

      private

      def set_current_organization
        return unless current_user
        @current_organization = current_user.organizations.first || Organization.first
      end

      def current_organization
        @current_organization
      end

      def manager_or_admin?(org = current_organization)
        return false unless current_user && org
        role = current_user.memberships.find_by(organization_id: org.id)&.role
        %w[manager admin].include?(role)
      end

      def skip_pundit?
        devise_controller?
      end

      def user_not_authorized
        redirect_to(request.referer || root_path, alert: '許可されていません。')
      end
    end
  RUBY

  # Projects/Tasks controller にauthorizeフックを追加
  inject_into_class 'app/controllers/projects_controller.rb', 'ProjectsController', <<~'RUBY'
      before_action :authorize_project_resource

      private
      def authorize_project_resource
        if defined?(@project) && @project.present?
          authorize @project
        else
          authorize Project
        end
      end
  RUBY

  inject_into_class 'app/controllers/tasks_controller.rb', 'TasksController', <<~'RUBY'
      before_action :authorize_task_resource

      private
      def authorize_task_resource
        if defined?(@task) && @task.present?
          authorize @task
        else
          authorize Task
        end
      end
  RUBY

  # TimeEntries index のフィルタ＆CSV対応と set_time_entry のpolicy_scope化
  gsub_file 'app/controllers/time_entries_controller.rb', /def index.*?end/m, <<~'RUBY'
      def index
        scope = policy_scope(TimeEntry).includes(:project, :task)

        from = params[:from].present? ? (Date.parse(params[:from]) rescue nil) : Date.today.beginning_of_week(:monday)
        to   = params[:to].present? ? (Date.parse(params[:to]) rescue nil) : Date.today.end_of_week(:monday)
        scope = scope.between(from, to) if from && to

        if params[:project_id].present?
          scope = scope.where(project_id: params[:project_id])
        end

        if manager_or_admin?(current_organization) && params[:user_id].present?
          scope = scope.where(user_id: params[:user_id])
        end

        @time_entries = scope.order(work_date: :desc)
        @projects = policy_scope(Project).order(:name)
        @users = manager_or_admin?(current_organization) ? current_organization.users.order(:email) : []

        respond_to do |format|
          format.html
          format.csv do
            filename = "time_entries-#{Date.today}.csv"
            headers['Content-Disposition'] = %(attachment; filename="#{filename}")
            headers['Content-Type'] = 'text/csv'
            render plain: CSV.generate(headers: true) { |csv|
              csv << %w[date project task hours minutes note billable]
              @time_entries.each do |e|
                csv << [e.work_date, e.project&.name, e.task&.name, e.hours, e.minutes, e.note, e.billable]
              end
            }
          end
        end
      end
  RUBY

  gsub_file 'app/controllers/time_entries_controller.rb', /def set_time_entry.*?end/m, <<~'RUBY'
      def set_time_entry
        @time_entry = policy_scope(TimeEntry).find(params[:id])
      end
  RUBY

  # フィルタフォームと一覧の上書き
  file 'app/views/time_entries/_filters.html.erb', <<~'ERB'
    <%= form_with url: time_entries_path, method: :get, local: true do %>
      <div style="display:flex; gap: 8px; align-items: end; flex-wrap: wrap;">
        <div>
          <label>期間 From</label>
          <%= date_field_tag :from, params[:from] || Date.today.beginning_of_week(:monday) %>
        </div>
        <div>
          <label>To</label>
          <%= date_field_tag :to, params[:to] || Date.today.end_of_week(:monday) %>
        </div>
        <div>
          <label>プロジェクト</label>
          <%= select_tag :project_id, options_from_collection_for_select(@projects, :id, :name, params[:project_id]), include_blank: '全て' %>
        </div>
        <% if manager_or_admin?(current_organization) %>
          <div>
            <label>ユーザー</label>
            <%= select_tag :user_id, options_from_collection_for_select(@users, :id, :email, params[:user_id]), include_blank: '自分/全て' %>
          </div>
        <% end %>
        <div>
          <%= submit_tag '絞り込み', class: 'btn' %>
          <%= link_to 'CSV', request.query_parameters.merge(format: :csv), class: 'btn' %>
        </div>
      </div>
    <% end %>
  ERB

  file 'app/views/time_entries/index.html.erb', <<~'ERB'
    <div class="prose">
      <h1>工数一覧</h1>
      <p>
        <%= link_to '新規工数', new_time_entry_path, class: 'btn' %>
        <%= link_to 'プロジェクト', projects_path, class: 'btn' %>
      </p>

      <%= render 'filters' %>

      <table>
        <thead>
          <tr>
            <th>日付</th>
            <th>プロジェクト</th>
            <th>タスク</th>
            <th>時間(h)</th>
            <th>メモ</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <% total = 0 %>
          <% @time_entries.each do |e| %>
            <% total += e.hours %>
            <tr>
              <td><%= e.work_date %></td>
              <td><%= e.project&.name %></td>
              <td><%= e.task&.name %></td>
              <td><%= e.hours %></td>
              <td><%= e.note %></td>
              <td>
                <%= link_to '表示', e %>
                <%= link_to '編集', edit_time_entry_path(e) %>
                <%= link_to '削除', e, method: :delete, data: { confirm: '削除しますか?' } %>
              </td>
            </tr>
          <% end %>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="3">合計</th>
            <th><%= total %> h</th>
            <th colspan="2"></th>
          </tr>
        </tfoot>
      </table>
    </div>
  ERB

  # 日本語ロケール（最低限）
  file 'config/locales/ja.yml', <<~'YAML'
    ja:
      hello: "こんにちは"
      activerecord:
        models:
          organization: 組織
          project: プロジェクト
          task: タスク
          time_entry: 工数
          user: ユーザー
        attributes:
          project:
            name: 名称
            client_name: 顧客名
            billable: 課金対象
          task:
            name: 名称
            billable: 課金対象
          time_entry:
            work_date: 日付
            minutes: 分
            note: メモ
            billable: 課金対象
            project: プロジェクト
            task: タスク
  YAML

  say_step 'インデックス/外部キーの追加マイグレーションを作成'
  rails_command "g migration AddFkToTimeEntriesApprovedBy"
  rails_command "g migration AddIndexesForPerformance"

  fk_mig = Dir['db/migrate/*_add_fk_to_time_entries_approved_by.rb'].first
  if fk_mig
    file fk_mig, <<~'RUBY'
      class AddFkToTimeEntriesApprovedBy < ActiveRecord::Migration[7.1]
        def change
          add_foreign_key :time_entries, :users, column: :approved_by_id
        end
      end
    RUBY
  end

  idx_mig = Dir['db/migrate/*_add_indexes_for_performance.rb'].first
  if idx_mig
    file idx_mig, <<~'RUBY'
      class AddIndexesForPerformance < ActiveRecord::Migration[7.1]
        def change
          add_index :time_entries, [:organization_id, :user_id, :project_id, :work_date], name: 'index_time_entries_on_org_user_project_date'
          add_index :memberships, [:organization_id, :user_id], unique: true
        end
      end
    RUBY
  end

  say_step 'DBマイグレーション実行'
  rails_command 'db:create'
  rails_command 'db:migrate'
  rails_command 'db:seed'

  say_step 'Annotate 実行（モデルにスキーマ注記）'
  rails_command 'annotate'

  say_step 'セットアップ完了！'
  git :init unless `git rev-parse --is-inside-work-tree 2>/dev/null`.strip == 'true'
  git add: '.'
  git commit: "-m 'Initial scaffold for time tracking app'"
end
