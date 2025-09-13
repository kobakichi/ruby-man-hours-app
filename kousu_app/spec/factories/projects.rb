FactoryBot.define do
  factory :project do
    organization { nil }
    name { "MyString" }
    client_name { "MyString" }
    billable { false }
    budget_hours { 1 }
    start_date { "2025-09-13" }
    end_date { "2025-09-13" }
  end
end
