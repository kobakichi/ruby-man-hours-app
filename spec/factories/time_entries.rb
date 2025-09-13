FactoryBot.define do
  factory :time_entry do
    organization { nil }
    user { nil }
    project { nil }
    task { nil }
    work_date { "2025-09-13" }
    minutes { 1 }
    note { "MyText" }
    billable { false }
    approved_at { "2025-09-13 18:37:33" }
    approved_by_id { 1 }
  end
end
