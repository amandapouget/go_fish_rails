class Game
  Game::MIN_PLAYERS = 2
  Game::MAX_PLAYERS = 5
  Game::PLAYER_RANGE = (Game::MIN_PLAYERS..Game::MAX_PLAYERS)

  attr_accessor :players, :deck, :hand_size, :requests, :next_turn
  attr_writer :winner

  def initialize(players: [], hand_size: 5)
    @players = players.size >= Game::MIN_PLAYERS ? players : Array.new(Game::MIN_PLAYERS) { Player.new }
    @deck = Card.deck
    @hand_size = hand_size
    @requests = []
    @next_turn = @players[0]
    raise ArgumentError, "Cannot have more than #{Game::MAX_PLAYERS} players" if players.size > Game::MAX_PLAYERS
    raise ArgumentError, "Hand size out of range" if (hand_size * players.size > @deck.count_cards || hand_size < 1)
  end

  def deal
    @deck.shuffle
    hand_size.times { @players.each { |player| player.add_card(@deck.deal_next_card) unless @deck.empty? } }
  end

  def winner
    @winner ||= game_over? ? player_with_most_books : NullPlayer.new
  end

  def player_with_most_books
    players_sorted = @players.clone.tap { |new_players| (new_players.sort_by! { |player| player.books.size }).reverse! }
    return players_sorted[0] if players_sorted[0].books.size > players_sorted[1].books.size
    return NullPlayer.new
  end

  def go_fish(player, rank)
    fish_card = player.go_fish(deck)
    advance_turn unless fish_card.rank == rank
    fish_card
  end

  def make_request(player, opponent, rank)
    @requests << RankRequest.new(player, opponent, rank).tap { |rank_request| rank_request.execute }
    @requests.last
  end

  def advance_turn
    next_player_index = @players.index { |player| player.user_id == @next_turn.user_id } + 1
    @next_turn = @players[next_player_index % @players.size]
  end

  def game_over?
    @deck.empty? || @players.any? { |player| player.out_of_cards? }
  end
end
