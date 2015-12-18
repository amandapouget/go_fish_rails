require 'rails_helper'
require 'benchmark'

RSpec.describe ApiController, type: :controller do
  include AuthenticationHelper

  let(:user) { create(:real_user) }

  describe '#authenticate' do
    context 'with valid login' do
      before do
        http_login user.email, user.password
        get :authenticate
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq user
      end

      it 'returns a success message' do
        expect(response.body).to include user.email
      end
    end

    context 'with invalid login' do
      before do
        get :authenticate, { email: "fake", password: "fake" }
      end

      it 'does not assign @user' do
        expect(assigns(:user)).to eq nil
      end

      it 'returns an invalid login message' do
        expect(response.body).to match /invalid/i
      end
    end
  end

  describe '#authenticate_user_from_token!' do
    let(:correct_token) { user.authentication_token }
    let(:incorrect_token) { correct_token.chop }

    def mock_route
      Rails.application.routes.draw do
        get '/authenticate_user_from_token!', to: "api#authenticate_user_from_token!"
      end
    end

    def reset_routes
     Rails.application.reload_routes!
    end

    it 'signs in a user if the token matches a user' do
      http_give_token(correct_token)
      current_user = controller.authenticate_user_from_token!
      expect(current_user).not_to be nil
    end

    it 'returns an invalid token message and 401:unauthorized if the token does not match a user' do
      mock_route
      http_give_token(incorrect_token)
      get :authenticate_user_from_token!
      expect(response.body).to match /invalid/i
      reset_routes
    end

    # it 'takes roughly the same amount of time to complete when given no token as when given an incorrect token (prevents timing attacks)' do
    #   http_give_token(incorrect_token)
    #   incorrect_token_time = Benchmark.measure { get :authenticate_user_from_token! }.real
    #   http_give_token("")
    #   no_token_time = Benchmark.measure { get :authenticate_user_from_token! }.real
    #   expect(incorrect_token_time - no_token_time).to be < 0.001
    # end
  end
end
