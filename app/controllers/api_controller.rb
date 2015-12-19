class ApiController < ApplicationController
  before_action :set_format_to_json
  before_action :authenticate_user_from_token!, except: [:authenticate]

  # POST /api/authenticate
  def authenticate
    authenticate_with_http_basic do |email, password|
      @user = User.find_by_email(email)
      render json: { error: 'invalid email or password' }, status: :unauthorized unless @user && @user.valid_password?(password)
    end
  end

  def authenticate_user_from_token!
    authenticate_with_http_token do |token|
      user = User.find_by_authentication_token(token)
      sign_in user, store: false and return current_user if user
    end
    render json: { error: 'invalid token' }, status: :unauthorized
  end

  # GET /api/new
  def new
    @player_range = Game::PLAYER_RANGE
  end

  # POST /api/create
  def create
    match_maker.match(current_user, params["num_players"].to_i)
    match = match_maker.start_match(current_user)
    match.users.each { |user| push(match, user) } if match
    return_success
  end

  def match_maker
    @@match_maker ||= MatchMaker.new
  end

private
  def set_format_to_json
    request.format = :json
  end

  def return_success
    render json: nil, status: :ok
  end

  def push(match, user)
    Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "/matches/#{match.id}" })
  end
end
