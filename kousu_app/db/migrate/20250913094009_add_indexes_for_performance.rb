class AddIndexesForPerformance < ActiveRecord::Migration[7.1]
  def change
    add_index :time_entries, [:organization_id, :user_id, :project_id, :work_date], name: 'index_time_entries_on_org_user_project_date'
    add_index :memberships, [:organization_id, :user_id], unique: true
  end
end
