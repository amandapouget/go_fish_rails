require 'rails_helper'

describe User do
  let(:user) { create(:real_user) }
  let(:match_recent) { create(:match, users: [user, create(:robot_user)]) }
  let(:match_old) { create(:match, users: [user, create(:real_user)]) }

  it 'knows how many points it has earned' do
    match_recent.game.winner = match_recent.player(user)
    match_recent.end_match
    expect(user.points).to be > 0
  end
end
