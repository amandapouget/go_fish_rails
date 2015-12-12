require 'pusher'
require 'pry'

class GameController < ApplicationController
  Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"

  def index
    @player_range = Game::PLAYER_RANGE
  end

  def wait
    @num_players = params["num_players"].to_i
    match_maker.match(current_user, @num_players)
  end

  def subscribed
    match = match_maker.start_match(current_user) || newly_created_match
    match.users.each { |user| push(match, user) } if match
    render json: nil, status: :ok
  end

  def start_with_robots
    num_players = params["num_players"].to_i
    match = make_robot_match(num_players) until match
    redirect_to "/#{match.id}/player/#{current_user.id}"
  end

  def show
    @match = Match.find(params["match_id"])
    @player = @match.player(current_user) if @match
    respond_to do |format|
      format.html { @player ? (render :show) : (render :no_show) }
      format.json { render json: @match.view(current_user) }
    end
  end

  def card_request
    match = Match.find_by_id(params["matchId"].to_i)
    opponent = match.players.find { |player| player.id == params["opponentUserId"].to_i }
    player = match.player(current_user)
    match.run_play(player, opponent, params["rank"])
    render json: nil, status: :ok
  end

  def match_maker
    @@match_maker ||= MatchMaker.new
  end

  def newly_created_match
    current_user.matches.sort_by { |match| match.created_at }.last unless match_maker.is_holding(current_user)
  end

  protected
    def make_robot_match(num_players)
      match_maker.match(RobotUser.create, num_players)
      match_maker.start_match(current_user)
    end

    def push(match, user)
      Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}/player/#{user.id}" })
    end
end
