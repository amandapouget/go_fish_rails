require 'rails_helper'

RSpec.describe "matches/new", type: :view do
  before(:each) do
    assign(:match, Match.new(
      :over => false,
      :message => "MyText",
      :hand_size => 1,
      :game => "MyText"
    ))
  end

  it "renders new match form" do
    render

    assert_select "form[action=?][method=?]", matches_path, "post" do

      assert_select "input#match_over[name=?]", "match[over]"

      assert_select "textarea#match_message[name=?]", "match[message]"

      assert_select "input#match_hand_size[name=?]", "match[hand_size]"

      assert_select "textarea#match_game[name=?]", "match[game]"
    end
  end
end
