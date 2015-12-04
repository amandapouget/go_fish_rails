require 'rails_helper'

RSpec.describe "matches/index", type: :view do
  before(:each) do
    assign(:matches, [
      Match.create!(
        :over => false,
        :message => "MyText",
        :hand_size => 1,
        :game => "MyText"
      ),
      Match.create!(
        :over => false,
        :message => "MyText",
        :hand_size => 1,
        :game => "MyText"
      )
    ])
  end

  it "renders a list of matches" do
    render
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
