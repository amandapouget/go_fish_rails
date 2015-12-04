require 'pusher'
require 'pry'

class GameController < ApplicationController
  Pusher.url = "https://39cc3ae7664f69e97e12:60bb9ff467a643cc4001@api.pusherapp.com/apps/151900"
  MyMatchMaker ||= MatchMaker.new

  def index
    @player_range = Game::PLAYER_RANGE
  end

  def wait
    @user = RealUser.create(name: params["name"])
    @num_players = params["num_players"].to_i
    match = match_maker.match(@user, @num_players)
    start(match) if match
  end

  def subscribed
    user = User.find(params["user_id"].to_i)
    match = user.matches.sort_by { |match| match.created_at }.last
    match.users.each { |user| push(match, user) } if match
    render json: nil, status: :ok
  end

  def start_with_robots
    user = User.find(params["user_id"].to_i)
    num_players = params["num_players"].to_i
    match = match_maker.match(RobotUser.new, num_players) until match
    start(match)
    redirect_to "/#{match.id}/player/#{user.id}"
  end

  def show
    @match = Match.find_by_id(params["match_id"].to_i)
    @player = @match.players.find { |player| player.user_id == params["user_id"].to_i } if @match
    if @player && params['format'] == 'json'
      return @match.view(@player).to_json
    elsif @player
      render 'show'
    else
      render 'no_show'
    end
  end

  def card_request
    match = Match.find_by_id(params["matchId"].to_i)
    opponent = match.players.find { |player| player.user_id == params["opponentUserId"].to_i }
    player = match.players.find { |player| player.user_id == params["playerUserId"].to_i }
    match.run_play(player, opponent, params["rank"])
    return nil
  end

  protected
    def match_maker
      MyMatchMaker
    end

    def start(match)
      match.game.deal
      match.save
    end

    def push(match, user)
      Pusher.trigger("waiting_for_players_channel_#{user.id}", 'send_to_game_event', { message: "#{match.id}/player/#{user.id}" })
    end
end
