require 'rails_helper'

RSpec.describe "projects/edit", type: :view do
  let(:project) {
    Project.create!(
      organization: nil,
      name: "MyString",
      client_name: "MyString",
      billable: false,
      budget_hours: 1
    )
  }

  before(:each) do
    assign(:project, project)
  end

  it "renders the edit project form" do
    render

    assert_select "form[action=?][method=?]", project_path(project), "post" do

      assert_select "input[name=?]", "project[organization_id]"

      assert_select "input[name=?]", "project[name]"

      assert_select "input[name=?]", "project[client_name]"

      assert_select "input[name=?]", "project[billable]"

      assert_select "input[name=?]", "project[budget_hours]"
    end
  end
end
