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
    context 'format is html' do
      before { get :new, { format: :html } }

      it 'assigns @player_range based on allowed range from Game model' do
        expect(assigns(:player_range)).to eq Game::PLAYER_RANGE
      end

      it "assigns a new match as @match" do
        expect(assigns(:match)).to be_a_new(Match)
      end
    end

    context 'format is json' do
      before { get :new, { format: :json } }

      it 'returns player_range based on allowed range from Game model' do
        expect(response.body).to match /player_range/
      end
    end
  end

  describe 'POST #create' do
    shared_examples_for "a route format that can create matches" do
      let(:user_joins_match) { post :create, { format: the_format, num_players: Game::MIN_PLAYERS } }
      let(:skip_wait_for_more_users) { controller.start_match(0) }
      let(:create_match_still_needs_one_user) { (Game::MIN_PLAYERS - 1).times { controller.match_maker.match(create(:real_user), Game::MIN_PLAYERS) } }

      context 'enough users join' do
        before { create_match_still_needs_one_user }

        it 'creates a match' do
          expect {
            user_joins_match
            skip_wait_for_more_users
          }.to change(Match, :count).by(1)
        end

        it 'returns success and triggers a push' do
          allow(controller).to receive(:push).and_return nil
          expect(controller).to receive(:push)
          user_joins_match
          skip_wait_for_more_users
          expect(response).to be_success
        end
      end

      context 'not enough users have joined' do
        it 'creates a match with robots' do
          expect { user_joins_match; skip_wait_for_more_users }.to change(Match, :count)
          expect(current_user.matches.order('created_at').last.users.any? { |user| user.is_a? RobotUser }).to be true
        end

        it 'returns success and triggers a push' do
          allow(controller).to receive(:push).and_return nil
          expect(controller).to receive(:push)
          user_joins_match
          skip_wait_for_more_users
          expect(response).to be_success
        end
      end
    end

    describe 'format :js' do
      it_should_behave_like "a route format that can create matches"
      let(:the_format) { :js }
    end

    describe 'format :json' do
      it_should_behave_like "a route format that can create matches"
      let(:the_format) { :json }
    end
  end

  describe 'GET #show' do
    let(:match) { create(:match, users: [current_user, create(:robot_user)]) }

    context 'html format' do
      let(:get_show) { get :show, { id: match.to_param } }
      let(:get_no_show) { get :show, { id: create(:match).to_param } }

      context 'user is part of the match' do
        it 'assigns the requested match as @match' do
          get_show
          expect(assigns(:match)).to eq match
        end

        it 'assigns the player for the current_user as @player' do
          get_show
          expect(match.user(assigns(:player))).to eq current_user
        end

        it 'returns the show view' do
          expect(get_show).to render_template(:show)
        end
      end

      context 'user is not part of the match' do
        it 'returns the no_show view if no @player is found' do
          expect(get_no_show).to render_template(:no_show)
        end
      end
    end

    context 'json format' do
      let(:get_show) { get :show, { format: :json, id: match.to_param } }
      let(:get_no_show) { get :show, { format: :json, id: create(:match).to_param } }

      context 'user is part of the match' do
        it 'returns the match view of the user' do
          get_show
          expect(response.body).to include match.view(current_user)
        end
      end

      context 'user is not part of the match' do
        it 'returns unauthorized' do
          get_no_show
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe 'PATCH/PUT #update' do
    let(:opponent) { create(:robot_user) }
    let(:match) { create(:match, :dealt, users: [current_user, opponent]) }
    let(:cards) { match.player(current_user).cards }

    shared_examples_for "a route format that can trigger updates" do
      before { post :update, { format: the_format, id: match.to_param, opponentUserId: opponent.id, rank: cards.sample.rank } }

      it 'causes game play to happen' do
        match.reload
        expect(match.player(current_user).cards).not_to eq cards
      end

      it 'returns a success message' do
        expect(response).to be_success
      end
    end

    describe 'format :js' do
      it_should_behave_like "a route format that can trigger updates"
      let(:the_format) { :js }
    end

    describe 'format :json' do
      it_should_behave_like "a route format that can trigger updates"
      let(:the_format) { :json }
    end
  end
end
