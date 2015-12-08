class Match < ActiveRecord::Base
  has_many :participations
  has_many :users, :through => :participations
  belongs_to :winner, class_name: 'User', foreign_key: 'winner_id'
  serialize :game
  after_create :set_defaults, :save

  FIRST_PROMPT = ", click card, player & me to request cards!"

  def set_defaults
    self.game ||= Game.new(players: self.users.map { |user| Player.new(name: user.name, id: user.id) }, hand_size: self.hand_size)
    self.game.next_turn = self.game.players.find { |player| user(player).is_a? RealUser } if game.requests.length == 0
    self.message ||= game.next_turn.name + FIRST_PROMPT
  end

  def notify_observers
    match_client_notifier.send_notice(self)
  end

  def match_client_notifier
    @match_client_notifier ||= MatchClientNotifier.new
  end

  def players
    game.players
  end

  def user(player)
    User.find_by_id(player.id) || NullUser.new
  end

  def player(user)
    players.find { |player| player.id == user.id } || NullPlayer.new
  end

  def opponents(player)
    players.clone.tap { |players| players.rotate!(players.index{ |available_player| available_player.id == player.id}).shift }
  end

  def view(player)
    return {
      message: self.message,
      player: player,
      player_index: players.index(player),
      opponents: opponents(player).map { |opponent| {id: opponent.id, name: opponent.name, icon: opponent.icon} },
      scores: players.map { |player| [player.name, player.books.size] }.push(["Fish Left", game.deck.count_cards])
    }.to_json
  end

  def run_play(player, opponent, rank) # would belong in a controller in a rails app
    if game.next_turn.id == player.id
      execute_turn(player, opponent, rank)
      save
      notify_observers
      next_user = user(game.next_turn)
      next_user.make_play(self) if next_user.is_a?(RobotUser) && !game.game_over?
    end
  end

  def execute_turn(player, opponent, rank)
    rank == "six" ? rank_word = "sixe" : rank_word = rank
    self.message = "#{player.name} asked #{opponent.name} for #{rank_word}s &"
    if game.make_request(player, opponent, rank).won_cards?
      self.message += " got cards"
    else
      self.message += " went fish"
      self.message += " & got one" if rank == game.go_fish(player, rank).rank
    end
    if game.game_over?
      end_match
      self.message += "! Game over! Winner: #{game.winner.name}"
    else
      self.message += "! It's #{game.next_turn.name}'s turn!"
    end
  end

  def winning_user
    user(game.winner) unless game.winner.is_a? NullPlayer
  end

  def end_match
    self.winner = winning_user
    participations.where(user: winner).each {|participation| participation.update_attribute(:points, 1)}
    update_column(:over, true)
  end
end
