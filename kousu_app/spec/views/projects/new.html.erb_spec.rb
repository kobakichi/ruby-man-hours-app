require 'rails_helper'

RSpec.describe "projects/new", type: :view do
  before(:each) do
    assign(:project, Project.new(
      organization: nil,
      name: "MyString",
      client_name: "MyString",
      billable: false,
      budget_hours: 1
    ))
  end

  it "renders new project form" do
    render

    assert_select "form[action=?][method=?]", projects_path, "post" do

      assert_select "input[name=?]", "project[organization_id]"

      assert_select "input[name=?]", "project[name]"

      assert_select "input[name=?]", "project[client_name]"

      assert_select "input[name=?]", "project[billable]"

      assert_select "input[name=?]", "project[budget_hours]"
    end
  end
end
