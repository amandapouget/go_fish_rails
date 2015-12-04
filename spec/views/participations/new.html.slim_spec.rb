require 'rails_helper'

RSpec.describe "participations/new", type: :view do
  before(:each) do
    assign(:participation, Participation.new(
      :match_id => 1,
      :user_id => 1
    ))
  end

  it "renders new participation form" do
    render

    assert_select "form[action=?][method=?]", participations_path, "post" do

      assert_select "input#participation_match_id[name=?]", "participation[match_id]"

      assert_select "input#participation_user_id[name=?]", "participation[user_id]"
    end
  end
end
