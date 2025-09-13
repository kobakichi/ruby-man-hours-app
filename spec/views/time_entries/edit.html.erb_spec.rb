require 'rails_helper'

RSpec.describe "time_entries/edit", type: :view do
  let(:time_entry) {
    TimeEntry.create!(
      organization: nil,
      user: nil,
      project: nil,
      task: nil,
      minutes: 1,
      note: "MyText",
      billable: false,
      approved_by_id: 1
    )
  }

  before(:each) do
    assign(:time_entry, time_entry)
  end

  it "renders the edit time_entry form" do
    render

    assert_select "form[action=?][method=?]", time_entry_path(time_entry), "post" do

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
