require 'rails_helper'

RSpec.describe "time_entries/index", type: :view do
  before(:each) do
    assign(:time_entries, [
      TimeEntry.create!(
        organization: nil,
        user: nil,
        project: nil,
        task: nil,
        minutes: 2,
        note: "MyText",
        billable: false,
        approved_by_id: 3
      ),
      TimeEntry.create!(
        organization: nil,
        user: nil,
        project: nil,
        task: nil,
        minutes: 2,
        note: "MyText",
        billable: false,
        approved_by_id: 3
      )
    ])
  end

  it "renders a list of time_entries" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
  end
end
