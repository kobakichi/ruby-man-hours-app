require 'rails_helper'

RSpec.describe "time_entries/show", type: :view do
  before(:each) do
    assign(:time_entry, TimeEntry.create!(
      organization: nil,
      user: nil,
      project: nil,
      task: nil,
      minutes: 2,
      note: "MyText",
      billable: false,
      approved_by_id: 3
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/3/)
  end
end
