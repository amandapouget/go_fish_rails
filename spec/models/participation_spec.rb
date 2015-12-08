require 'rails_helper'

describe Participation do
  let(:user) { create(:real_user) }
  let(:match) { create(:match, users: [user, create(:real_user)]) }
  let(:participation) { Participation.find_by(match: match, user: user) }

  it 'pairs users and matches' do
    expect(participation.match_id).to eq match.id
    expect(participation.user).to eq user
    expect(participation.match).to eq match
  end
  it 'tracks the points earned' do
    expect(participation.points).to eq 0
  end
  it 'can be used to tell you user rankings' do

  end
  it 'excludes robot users from the rankings' do

  end
  it 'can be used to tell you user history' do

  end
end
