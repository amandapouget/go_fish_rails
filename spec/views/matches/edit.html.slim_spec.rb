require 'rails_helper'

RSpec.describe "matches/edit", type: :view do
  before(:each) do
    @match = assign(:match, Match.create!(
      :over => false,
      :message => "MyText",
      :hand_size => 1,
      :game => "MyText"
    ))
  end

  it "renders the edit match form" do
    render

    assert_select "form[action=?][method=?]", match_path(@match), "post" do

      assert_select "input#match_over[name=?]", "match[over]"

      assert_select "textarea#match_message[name=?]", "match[message]"

      assert_select "input#match_hand_size[name=?]", "match[hand_size]"

      assert_select "textarea#match_game[name=?]", "match[game]"
    end
  end
end
