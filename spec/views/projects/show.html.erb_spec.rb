require 'rails_helper'

RSpec.describe "projects/show", type: :view do
  before(:each) do
    assign(:project, Project.create!(
      organization: nil,
      name: "Name",
      client_name: "Client Name",
      billable: false,
      budget_hours: 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Client Name/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/2/)
  end
end
