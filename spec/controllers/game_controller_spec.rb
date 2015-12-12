require 'rails_helper'

RSpec.describe GameController, type: :controller do
  let(:current_user) { create(:real_user) }

  before do
    controller.match_maker.reset
    sign_in current_user
  end

  describe 'GET #index' do
    it 'assigns @player_range based on allowed range from Game model' do
      get :index, {}
      expect(assigns(:player_range)).to eq Game::PLAYER_RANGE
    end
  end

  describe 'POST #wait' do
    it 'assigns the num_players as @num_players' do
      post :wait, { num_players: Game::MIN_PLAYERS }
      expect(assigns(:num_players)).to eq Game::MIN_PLAYERS
    end
  end

  describe 'POST #subscribed' do
    it 'does not create a match when there are not enough users' do
      expect {
        (Game::MIN_PLAYERS - 1).times { post :wait, { num_players: Game::MIN_PLAYERS } }
      }.not_to change(Match, :count)
    end

    it 'returns a success message' do
      post :subscribed
      expect(response).to be_success
    end

    context 'enough users have joined' do
      before do
        Game::MIN_PLAYERS.times { post :wait, { num_players: Game::MIN_PLAYERS } }
      end

      it 'it creates a match when there are enough users' do
        expect { post :subscribed }.to change(Match, :count).by(1)
      end

      it 'readies the match for play by dealing the cards if it creates a match' do
        post :subscribed
        expect(controller.newly_created_match.game.game_over?).to be false
      end

      it 'triggers a push' do
        Game::MIN_PLAYERS.times do
          allow(controller).to receive(:push).and_return nil
          expect(controller).to receive(:push)
          post :subscribed
        end
      end
    end

    it 'triggers a push when the enough users subscribe in a different order' do
      Game::MIN_PLAYERS.times do
        post :wait, { num_players: Game::MIN_PLAYERS }
        allow(controller).to receive(:push).and_return nil
        expect(controller).to receive(:push)
        post :subscribed
      end
    end
  end

  describe 'POST #start_with_robots' do
    before do
      post :wait, { num_players: Game::MIN_PLAYERS }
    end

    it 'it creates a match with the user and some robots' do
      post :start_with_robots, { num_players: Game::MIN_PLAYERS }
      match = controller.newly_created_match
      expect(match.users).to include current_user
      expect(match.users.any? { |user| user.is_a? RobotUser }).to be true
    end

    it 'redirects to the match page' do
      post :start_with_robots, { num_players: Game::MIN_PLAYERS }
      expect(response).to redirect_to /.[0-9]\/player\/.[0-9]/
    end
  end

  describe 'GET #show' do
    let(:match) { create(:match, users: [current_user, create(:robot_user)]) }
    let(:match_without_current_user) { create(:match) }
    let(:get_show) { get :show, { match_id: match.id } }
    let(:get_show_json) { get :show, format: :json, match_id: match.id }
    let(:get_no_show) { get :show, { match_id: match_without_current_user.id } }

    it 'assigns the match as @match' do
      get_show
      expect(assigns(:match)).to eq match
    end

    it 'assigns from the match the player for the current_user as @player' do
      get_show
      expect(match.user(assigns(:player))).to eq current_user
    end

    it 'returns the show view if @player' do
      expect(get_show).to render_template(:show)
    end

    it 'returns the no_show view if no @player is found' do
      expect(get_no_show).to render_template(:no_show)
    end

    it 'returns a json-ified @match.view(player) if format is json' do
      get_show_json
      expect(response.body).to include match.view(current_user)
    end
    # will probably need to account for json-no-show case for api
  end

  describe 'POST #card_request' do
    let(:opponent) { create(:robot_user) }
    let(:match) { create(:match, :dealt, users: [current_user, opponent]) }
    let(:post_card_request) { post :card_request, matchId: match.id }
    let(:cards) { match.player(current_user).cards }

    before do
      post :card_request, matchId: match.id, opponentUserId: opponent.id, rank: cards.sample.rank
    end

    it 'causes game play to happen' do
      match.reload
      expect(match.player(current_user).cards).not_to eq cards
    end

    it 'returns a success message' do
      expect(response).to be_success
    end
  end

  # User/new
  # it 'creates a new User' do
  #   expect {
  #     post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS }
  #   }.to change(User, :count).by(1)
  # end

  # User/new -- need to test Devise? :-)
  # it 'assigns a newly created user as current_user' do
  #   post :wait, { name: "Amanda", num_players: Game::MIN_PLAYERS }
  #   expect(assigns(:user)).to be_a(User)
  #   expect(assigns(:user)).to be_persisted
  # end
end
