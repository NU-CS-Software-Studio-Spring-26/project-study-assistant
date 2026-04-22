json.extract! assignment, :id, :title, :course_name, :due_date, :estimated_hours, :synced_to_calendar, :created_at, :updated_at
json.url assignment_url(assignment, format: :json)
