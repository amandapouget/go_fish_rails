class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!, except: [:authenticate]

  def authenticate
    authenticate_with_http_basic do |email, password|
      user = User.find_by_email(email)
      @user = user if user.valid_password?(password)
    end
    render 'authenticate.json.jbuilder'
  end

  def my_secret_endpoint
    render 'my_secret_endpoint.json.jbuilder'
  end

  def authenticate_user_from_token!
    authenticate_with_http_token do |token|
      # Devise.secure_compare(token,token)
      user = User.find_by_authentication_token(token)
      sign_in user, store: false and return current_user if user
    end
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
end
