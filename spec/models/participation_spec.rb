require 'rails_helper'

describe Participation do
  let(:user) { create(:real_user) }
  let(:match) { create(:match, users: [user, create(:real_user)]) }
  let(:participation) { Participation.find_by_match_and_user(match, user) }

  it 'pairs users and matches' do
    expect(participation.match_id).to eq match.id
    expect(participation.user).to eq user
    expect(participation.match).to eq match
  end
  it 'tracks participation result, including (potentially weighted) points earned' do # could track tournament - match - user link
    expect(participation.points).to eq 0
    match.winner = user
    Participation.set_points(match)
    participation.reload
    expect(participation.points).to eq 1
  end
  it 'can be used to tell you user rankings' do

  end
  it 'excludes robot users from the rankings' do

  end
  it 'can be used to tell you user history' do

  end
end
