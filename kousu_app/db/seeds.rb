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
