json.extract! task, :id, :project_id, :name, :billable, :created_at, :updated_at
json.url task_url(task, format: :json)
