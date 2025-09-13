json.extract! time_entry, :id, :organization_id, :user_id, :project_id, :task_id, :work_date, :minutes, :note, :billable, :approved_at, :approved_by_id, :created_at, :updated_at
json.url time_entry_url(time_entry, format: :json)
