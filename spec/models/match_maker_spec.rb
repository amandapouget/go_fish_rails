require 'rails_helper'

describe MatchMaker do
  let(:number_of_players) { 2 }
  let(:match_maker) { MatchMaker.new }
  let(:user) { create(:real_user) }
  let(:another_user) { create(:real_user) }

  before do
    match_maker.match(user, number_of_players)
  end

  context 'has the right number of users' do
    it 'makes a dealt match immediately' do
      match_maker.match(another_user, number_of_players)
      match = match_maker.start_match(user)
      expect(match.users).to contain_exactly(user, another_user)
      match.game.players.each { |player| expect(player.cards).not_to be_empty }
    end
  end

  context 'does not have the right number of users' do
    it 'adds robots and makes a dealt match' do
      match = match_maker.start_match(user, add_robots: true)
      expect(match.users).to include user
      expect(match.users.any? { |user| user.is_a? RobotUser }).to be true
    end
  end

  it 'does not make a match when the user is not in the queue' do
    match_maker.reset
    expect(match_maker.start_match(user)).to be nil
  end

  it 'does not match users wanting a different number of opponents' do
    match_maker.match(another_user, 3)
    match = match_maker.start_match(user)
    expect(match).to be_nil
  end

  it 'can tell you if a user in pending_users' do
    expect(match_maker.is_holding?(user)).to be true
    expect(match_maker.is_holding?(another_user)).to be false
  end

  it 'can reset the pending_users to empty' do
    match_maker.reset
    expect(match_maker.pending_users).to eq Hash.new
  end
end
