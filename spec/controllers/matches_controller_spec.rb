require 'rails_helper'

RSpec.describe MatchesController, type: :controller do
  let(:current_user) { create(:real_user) }

  before do
    controller.match_maker.reset
    sign_in current_user
  end

  describe "GET #index" do
    it "assigns all matches as @matches" do
      match = create(:match)
      get :index
      expect(assigns(:matches)).to eq([match])
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns @player_range based on allowed range from Game model' do
      expect(assigns(:player_range)).to eq Game::PLAYER_RANGE
    end

    it "assigns a new match as @match" do
      expect(assigns(:match)).to be_a_new(Match)
    end
  end

  describe 'POST #create' do
    def user_joins_match
      post :create, { format: :js, num_players: Game::MIN_PLAYERS }
    end

    def create_but_need_one_user
      (Game::MIN_PLAYERS - 1).times { user_joins_match }
    end

    context 'not enough users have joined' do
      it 'does not create a match when there are not enough users' do
        expect { create_but_need_one_user }.not_to change(Match, :count)
        expect(controller.match_maker.is_holding?(current_user)).to be true
      end

      it 'returns success [wait message?]' do
        create_but_need_one_user
        expect(response).to be_success
      end

      it 'does not trigger a push' do
        allow(controller).to receive(:push).and_return nil
        expect(controller).not_to receive(:push)
        create_but_need_one_user
      end
    end

    context 'enough users join' do
      before { create_but_need_one_user }

      it 'creates a match when there are enough users' do
        expect { user_joins_match }.to change(Match, :count).by(1)
      end

      it 'returns success [wait message?]' do
        user_joins_match
        expect(response).to be_success
      end

      it 'triggers a push' do
        allow(controller).to receive(:push).and_return nil
        expect(controller).to receive(:push)
        user_joins_match
      end
    end
  end

  describe 'GET #show' do
    let(:match) { create(:match, users: [current_user, create(:robot_user)]) }
    let(:get_show) { get :show, {id: match.to_param} }
    let(:get_show_json) { get :show, format: :json, id: match.to_param }
    let(:get_no_show) { get :show, {id: create(:match).to_param} }

    it 'assigns the requested match as @match' do
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

    it 'returns json: @match.view(player) if format is json' do
      get_show_json
      expect(response.body).to include match.view(current_user)
    end
    # will probably need to account for json-no-show case for api
  end

  describe 'POST #update' do
    let(:opponent) { create(:robot_user) }
    let(:match) { create(:match, :dealt, users: [current_user, opponent]) }
    let(:cards) { match.player(current_user).cards }

    before do
      post :update, id: match.to_param, opponentUserId: opponent.id, rank: cards.sample.rank
    end

    it 'causes game play to happen' do
      match.reload
      expect(match.player(current_user).cards).not_to eq cards
    end

    it 'returns a success message' do
      expect(response).to be_success
    end
  end
end
