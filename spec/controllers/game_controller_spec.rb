require 'rails_helper'

RSpec.describe GameController, type: :controller do
  describe 'GET #index' do
    it 'assigns @player_range based on allowed range from Game model' do
      get :index, {}
      expect(assigns(:player_range)).to eq Game::PLAYER_RANGE
    end
  end

  describe 'POST #wait' do
    before do
      reset_match_maker
    end

    def reset_match_maker
      GameController::MyMatchMaker.reset
    end

    it 'creates a new User' do
      expect {
        post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS }
      }.to change(User, :count).by(1)
    end

    it 'assigns a newly created user as @user' do
      post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS }
      expect(assigns(:user)).to be_a(User)
      expect(assigns(:user)).to be_persisted
    end

    it 'assigns the num_players as @num_players' do
      post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS }
      expect(assigns(:num_players)).to eq Game::MIN_PLAYERS
    end

    it 'it creates a match when there are enough users' do
      expect {
        Game::MIN_PLAYERS.times { post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS } }
      }.to change(Match, :count).by(1)
    end

    it 'does not create a match when there are not enough users' do
      expect {
        (Game::MIN_PLAYERS - 1).times { post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS } }
      }.not_to change(Match, :count)
    end

    it 'readies the match for play by dealing the cards if it creates a match' do
      Game::MIN_PLAYERS.times { post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS } }
      expect(Match.all.last.game.game_over?).to be false
    end
  end

  describe 'POST #subscribed' do
    it 'returns nil' do
      user = create(:user)
      response = post :subscribed, { user_id: user.id }
      expect(response).to be_success
    end
  end

  describe 'POST #subscribed' do
    it 'triggers a push' do
      user = create(:user)
      match = create(:match, users: [user, create(:user)])
      binding.pry
      allow(self).to receive(:push).and_return nil
      post :subscribed, { user_id: user.id }
      expect(self).to receive(:push)
    end
  end

  describe 'GET #show' do
  end

  describe 'POST #card_request' do
  end
end
