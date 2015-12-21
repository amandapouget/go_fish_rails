require 'rails_helper'
require 'benchmark'

RSpec.describe ApiController, type: :controller do
  include AuthenticationHelper

  let(:user) { create(:real_user) }
  let(:correct_token) { user.authentication_token }
  let(:incorrect_token) { correct_token.chop }

  after do
    controller.match_maker.reset
  end

  describe 'POST #authenticate' do
    context 'with valid login' do
      before do
        http_login user.email, user.password
        post :authenticate
      end

      it 'returns the user email and authentication_token' do
        expect(response.body).to include user.email
        expect(response.body).to include user.authentication_token
      end
    end

    context 'with invalid login' do
      before do
        http_login "fake", "fake"
        post :authenticate
      end

      it 'returns an invalid login message' do
        expect(response.body).to match /invalid/i
      end
    end
  end

  describe '#authenticate_user_from_token!' do
    it 'signs in a user if the token matches a user' do
      http_give_token(correct_token)
      current_user = controller.authenticate_user_from_token!
      expect(current_user).not_to be nil
    end

    def mock_route
      Rails.application.routes.draw { get '/authenticate_user_from_token!', to: "api#authenticate_user_from_token!" }
    end

    def reset_routes
     Rails.application.reload_routes!
    end

    it 'returns an invalid token message and 401:unauthorized if the token does not match a user' do
      mock_route
      http_give_token(incorrect_token)
      get :authenticate_user_from_token!
      expect(response.body).to match /invalid/i
      expect(response).to have_http_status(:unauthorized)
      reset_routes
    end
  end

  describe 'certain routes require a token' do
    it 'returns invalid without the token' do
      [->{ get :new }, ->{ post :create }, ->{ post :start_with_robots }].each do |route|
        route.call
        expect(response.body).to match /invalid/i
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'correct_token provided' do
    before { http_give_token(correct_token) }

    describe 'GET #new' do
      it 'returns player_range based on allowed range from Game model' do
        get :new
        expect(response.body).to match /player_range/
      end
    end

    describe 'POST #create' do
      def user_joins_match
        post :create, { num_players: Game::MIN_PLAYERS }
      end

      def create_but_need_one_user
        (Game::MIN_PLAYERS - 1).times { user_joins_match }
      end

      context 'not enough users have joined' do
        it 'does not create a match when there are not enough users' do
          expect { create_but_need_one_user }.not_to change(Match, :count)
          expect(controller.match_maker.is_holding?(user)).to be true
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

    describe 'POST #start_with_robots' do
      context 'user is in pending_users' do
        before do
          post :create, { num_players: Game::MIN_PLAYERS }
        end

        it 'it creates a match with the user and some robots' do
          expect { post :start_with_robots }.to change(Match, :count).by(1)
          match = Match.all.order(:created_at).last
          expect(match.users).to include user
          expect(match.users.any? { |user| user.is_a? RobotUser }).to be true
        end

        it 'returns success' do
          post :start_with_robots
          expect(response).to be_success
        end

        it 'triggers a push' do
          allow(controller).to receive(:push).and_return nil
          expect(controller).to receive(:push)
          post :start_with_robots
        end
      end

      context 'user is not in pending_users' do
        it 'does not create a match' do
          expect { post :start_with_robots }.not_to change(Match, :count)
        end

        it 'returns a failure' do
          post :start_with_robots
          expect(response).to have_http_status(:precondition_failed)
        end

        it 'does not trigger a push' do
          allow(controller).to receive(:push).and_return nil
          expect(controller).not_to receive(:push)
          post :start_with_robots
        end
      end
    end
  end
end
