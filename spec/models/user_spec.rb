require 'rails_helper'

def current_match
  unfinished_matches = matches.select { |match| match.over? == false }
  unfinished_matches.sort_by { |match| match.updated_at }.last
end

describe User do
  let(:user) { create(:real_user) }
  let(:match_recent) { create(:match, users: [user, create(:robot_user)]) }
  let(:match_old) { create(:match, users: [user, create(:real_user)]) }

  it 'can tell you the most recently updated, on-going match it has been a part of' do
    match_old.game.deal
    match_recent.game.deal
    expect(user.current_match).to eq match_recent
  end

  it 'returns nil if it has no on-going matches' do
    match_recent.game.deal
    match_recent.end_match
    expect(user.current_match).to eq nil
  end

  it 'knows how many points it has earned' do
    match_recent.game.winner = match_recent.player(user)
    match_recent.end_match
    expect(user.points).to be > 0
  end
end
