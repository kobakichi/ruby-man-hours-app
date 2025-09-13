FactoryBot.define do
  factory :task do
    project { nil }
    name { "MyString" }
    billable { false }
  end
end
