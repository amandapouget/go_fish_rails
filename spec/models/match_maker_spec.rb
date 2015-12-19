require 'rails_helper'

describe MatchMaker do
  let(:match_maker) { MatchMaker.new }
  let(:user) { create(:real_user) }
  let(:another_user) { create(:real_user) }

  before do
    match_maker.match(user, 2)
  end

  it 'makes a match with a dealt game when it has the right number of users' do
    match_maker.match(another_user, 2)
    match = match_maker.start_match(user)
    expect(match.users).to contain_exactly(user, another_user)
    match.game.players.each { |player| expect(player.cards).not_to be_empty }
  end

  it 'does not make a match when it does not have the right number of users' do
    expect(match_maker.start_match(user)).to be_nil
  end

  it 'does not match users wanting different number of opponents' do
    match_maker.match(another_user, 3)
    match = match_maker.start_match(user)
    expect(match).to be_nil
  end

  it 'can tell you if has a user in pending_users' do
    expect(match_maker.is_holding?(user)).to be true
    expect(match_maker.is_holding?(another_user)).to be false
  end

  it 'can reset the pending_users to empty' do
    match_maker.reset
    expect(match_maker.pending_users).to eq Hash.new
  end
end
