require 'rails_helper'

RSpec.describe "participations/index", type: :view do
  before(:each) do
    assign(:participations, [
      Participation.create!(
        :match_id => 1,
        :user_id => 2
      ),
      Participation.create!(
        :match_id => 1,
        :user_id => 2
      )
    ])
  end

  it "renders a list of participations" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
