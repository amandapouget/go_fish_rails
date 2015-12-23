class MatchesController < ApplicationController
  before_action :authenticate_user!, except: :simulate_start
  before_action :set_match, only: [:show, :update]

  Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    @player = @match.player(current_user) if @match
    respond_to do |format|
      format.html { @player ? (render :show) : (render :no_show) }
      format.json { render json: @match.view(current_user) }
    end
  end

  # GET /matches/new
  def new
    @match = Match.new
    @player_range = Game::PLAYER_RANGE
  end

  # POST /matches
  # POST /matches.json
  def create
    match_maker.match(current_user, params["num_players"].to_i)
    Thread.start do
      match = match_maker.start_match_thread(current_user)
      push(match) if match
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    opponent = @match.player(User.find(params["opponentUserId"].to_i))
    @match.run_play(@match.player(current_user), opponent, params["rank"])
    return success
  end

  def match_maker
    @@match_maker ||= MatchMaker.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    def push(match)
      match.users.each do |user|
        Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}" } )
      end
    end

    def success
      render json: nil, status: :ok
    end
end
