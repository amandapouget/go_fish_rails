class ApiController < ApplicationController
  before_action :set_format_to_json
  before_action :authenticate_user_from_token!, except: [:authenticate]
  before_action :set_match, only: [:show, :update]

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
    push(match) if match
    render json: nil, status: :ok
  end

  # POST /api/start_with_robots
  def start_with_robots
    match = match_maker.start_match(current_user, robots: true)
    if match
      push(match)
      render json: nil, status: :ok
    else
      render json: { error: 'missing number of players' }, status: :precondition_failed
    end
  end

  # PATCH/PUT /api/matches/
  def update
    opponent = @match.player(User.find(params["opponentUserId"].to_i))
    @match.run_play(@match.player(current_user), opponent, params["rank"])
    render json: nil, status: :ok
  end

  # GET /api/matches/1
  def show
    if @match.users.include?(current_user)
      render json: @match.view(current_user)
    else
      render json: { error: 'unauthorized match' }, status: :unauthorized
    end
  end

  def match_maker
    @@match_maker ||= MatchMaker.new
  end

private
  def set_format_to_json
    request.format = :json
  end

  def set_match
    @match = Match.find(params[:id])
  end

  def push(match)
    match.users.each do |user|
      Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}" } )
    end
  end
end
