require 'rails_helper'

RSpec.describe "time_entries/new", type: :view do
  before(:each) do
    assign(:time_entry, TimeEntry.new(
      organization: nil,
      user: nil,
      project: nil,
      task: nil,
      minutes: 1,
      note: "MyText",
      billable: false,
      approved_by_id: 1
    ))
  end

  it "renders new time_entry form" do
    render

    assert_select "form[action=?][method=?]", time_entries_path, "post" do

      assert_select "input[name=?]", "time_entry[organization_id]"

      assert_select "input[name=?]", "time_entry[user_id]"

      assert_select "input[name=?]", "time_entry[project_id]"

      assert_select "input[name=?]", "time_entry[task_id]"

      assert_select "input[name=?]", "time_entry[minutes]"

      assert_select "textarea[name=?]", "time_entry[note]"

      assert_select "input[name=?]", "time_entry[billable]"

      assert_select "input[name=?]", "time_entry[approved_by_id]"
    end
  end
end
