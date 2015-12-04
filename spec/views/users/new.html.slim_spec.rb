require 'rails_helper'

RSpec.describe "users/new", type: :view do
  before(:each) do
    assign(:user, User.new(
      :name => "MyString",
      :type => "MyText",
      :think_time => 1
    ))
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", users_path, "post" do

      assert_select "input#user_name[name=?]", "user[name]"

      assert_select "textarea#user_type[name=?]", "user[type]"

      assert_select "input#user_think_time[name=?]", "user[think_time]"
    end
  end
end
