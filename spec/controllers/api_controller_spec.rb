require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  include AuthenticationHelper

  let(:user) { create(:real_user) }
  let(:correct_token) { user.authentication_token }
  let(:incorrect_token) { correct_token.chop }

  before do
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
        expect(response.body).to include user.id.to_s
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
    context 'token matches user' do
      it 'signs in a user' do
        http_give_token(correct_token)
        current_user = controller.authenticate_user_from_token!
        expect(current_user).not_to be nil
      end
    end

    def mock_route
      Rails.application.routes.draw { get '/authenticate_user_from_token!', to: "api#authenticate_user_from_token!" }
    end

    def reset_routes
     Rails.application.reload_routes!
    end

    context 'token does not match user' do
      it 'returns invalid and :unauthorized' do
        mock_route
        http_give_token(incorrect_token)
        get :authenticate_user_from_token!
        expect(response.body).to match /invalid/i
        expect(response).to have_http_status(:unauthorized)
        reset_routes
      end
    end
  end

  describe 'certain routes require a token' do
    it 'returns invalid and :unauthorized without the token' do
      my_match = create(:match)
      [->{ get :new }, ->{ post :create }, ->{ patch :update, id: my_match.id }, ->{ get :show, id: my_match.id }].each do |route|
        route.call
        expect(response.body).to match /invalid/i
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # context 'correct_token provided' do
  #   before { http_give_token(correct_token) }
  #
  #   describe 'GET #new' do
  #     it 'returns player_range based on allowed range from Game model' do
  #       get :new
  #       expect(response.body).to match /player_range/
  #     end
  #   end
  #
  #   describe 'POST #create' do
  #     def user_joins_match
  #       post :create, { num_players: Game::MIN_PLAYERS }
  #       controller.start_match(0)
  #     end
  #
  #     def create_but_need_one_user
  #       (Game::MIN_PLAYERS - 1).times { user_joins_match }
  #     end
  #
  #     context 'enough users join' do
  #       before { create_but_need_one_user }
  #
  #       it 'creates a match' do
  #         expect { user_joins_match }.to change(Match, :count).by(1)
  #       end
  #
  #       it 'returns success' do
  #         user_joins_match
  #         expect(response).to be_success
  #       end
  #
  #       it 'triggers a push' do
  #         allow(controller).to receive(:push).and_return nil
  #         expect(controller).to receive(:push)
  #         user_joins_match
  #       end
  #     end
  #
  #     context 'not enough users have joined' do
  #       it 'creates a match with robots' do
  #         expect { create_but_need_one_user }.to change(Match, :count)
  #         expect(current_user.matches.order('created_at').last.users.any? { |user| user.is_a? RobotUser }).to be true
  #       end
  #     end
  #   end
  #
  #   describe 'GET #show' do
  #     let(:match) { create(:match, users: [user, create(:robot_user)]) }
  #     let(:get_show) { get :show, {id: match.to_param} }
  #     let(:get_no_show) { get :show, {id: create(:match).to_param} }
  #
  #     context 'user is part of the match' do
  #       it 'returns the match view of the user' do
  #         get_show
  #         expect(response.body).to include match.view(user)
  #       end
  #     end
  #
  #     context 'user is not part of the match' do
  #       it 'returns unauthorized' do
  #         get_no_show
  #         expect(response).to have_http_status(:unauthorized)
  #       end
  #     end
  #   end
  #
  #   describe 'PATCH/PUT #update' do
  #     let(:opponent) { create(:robot_user) }
  #     let(:match) { create(:match, :dealt, users: [user, opponent]) }
  #     let(:cards) { match.player(user).cards }
  #
  #     before do
  #       post :update, id: match.to_param, opponentUserId: opponent.id, rank: cards.sample.rank
  #     end
  #
  #     it 'causes game play to happen' do
  #       match.reload
  #       expect(match.player(user).cards).not_to eq cards
  #     end
  #
  #     it 'returns a success message' do
  #       expect(response).to be_success
  #     end
  #   end
  # end
end
