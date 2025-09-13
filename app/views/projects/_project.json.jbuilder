json.extract! project, :id, :organization_id, :name, :client_name, :billable, :budget_hours, :start_date, :end_date, :created_at, :updated_at
json.url project_url(project, format: :json)
