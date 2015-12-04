require 'rails_helper'

RSpec.describe "matches/show", type: :view do
  before(:each) do
    @match = assign(:match, Match.create!(
      :over => false,
      :message => "MyText",
      :hand_size => 1,
      :game => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/MyText/)
  end
end
