require 'rails_helper'

describe Player do
  describe '#initialize' do
    it 'creates a player object with an id, a name, an icon, an array for holding cards, and an array for holding books' do
      player = Player.new(name: "John")
      expect(player.id).to eq nil
      expect(player.name).to eq "John"
      expect(player.cards).to eq []
      expect(player.books).to eq []
      expect(player.icon).to be > ""
    end

    it 'defaults to Anonymous if no name is given' do
      expect(Player.new.name).to eq "Anonymous"
    end
  end

  context 'player has cards' do
    cards = [:card_3h, :card_2c, :card_2d, :card_3c, :card_3d, :card_7h, :card_2h, :card_2s]
    cards.each { |card| let(card) { build(card) } }
    let(:player) { build(:player, cards: cards[0..2]) }
    let(:opponent) { build(:player, cards: cards[3..5]) }
    let(:deck) { build(:deck, cards: [cards[6]]) }

    def check_sorted
      value = 0
      player.cards.each do |card|
        expect(card.rank_value).to be >= value
        value = card.rank_value
      end
    end

    describe '#give_cards' do
      it 'returns an array of cards with all the cards from the players cards that match the rank demanded' do
        expect(player.give_cards("two")).to match_array [card_2c, card_2d]
      end

      it 'returns an empty array if no such cards are found' do
        expect(player.give_cards("nine")).to match_array []
      end

      it 'removes the cards from the players hand' do
        player.give_cards("two")
        expect(player.cards).to match_array [card_3h]
      end
    end

    describe '#request_cards' do
      it 'asks another player to return cards of a given rank' do
        expect(player.request_cards(opponent, "three")).to match_array [card_3c, card_3d]
      end

      it 'returns an empty array if not given a proper player in the argument' do
        expect(player.request_cards("Friend", "three")).to eq []
      end

      it 'returns an empty array if the requester does not have a card of that rank themselves' do
        expect(player.request_cards(opponent, "seven")).to eq []
      end

      it 'returns an empty array if the opponent does not have the rank requested' do
        expect(player.request_cards(opponent, "two")).to eq []
      end
    end

    describe '#collect_winnings' do
      it 'collects all the winnings from a particular play and adds the cards to the players cards' do
        player.collect_winnings([card_3c, card_3d])
        expect(player.cards).to (include card_3c).and include card_3d
      end

      it 'politely sorts the players cards by rank for easy visualization' do
        player.collect_winnings([])
        check_sorted
      end

      it 'makes any possible books and moves those cards to the players books' do
        player.collect_winnings([card_2s, card_2h])
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
      end
    end

    describe '#go_fish' do
      it 'takes a card from the deck, adds it to the players cards and returns it' do
        go_fish_card = deck.cards[0]
        expect(player.go_fish(deck)).to eq go_fish_card
        expect(player.cards).to include go_fish_card
        expect(deck.cards).not_to include go_fish_card
      end

      it 'politely sorts the players cards' do
        player.go_fish(deck)
        check_sorted
      end

      it 'makes any possible books and moves those cards to the players books' do
        player.add_card(card_2s)
        player.go_fish(deck)
        expect(player.books[0]).to match_array [card_2h, card_2c, card_2d, card_2s]
      end
    end

    describe '#add_card' do
      it 'adds a card to the players cards at the bottom' do
        player.add_card(card_7h)
        expect(player.cards.last).to eq card_7h
      end
    end

    describe '#count_cards' do
      it 'returns the number of cards a player has' do
        expect(player.count_cards).to eq player.cards.size
      end
    end

    describe '#out_of_cards?' do
      it 'returns false when the player still has cards' do
        expect(player.out_of_cards?).to be false
      end
      it 'returns true when the player has no more cards' do
        player.cards = []
        expect(player.out_of_cards?).to be true
      end
    end

    describe '#to_json' do
      it 'returns a hash of the player name, cards, books and icon' do
        expect(player.to_json).to eq "{\"id\":null,\"name\":\"#{player.name}\",\"cards\":#{player.cards.to_json},\"books\":#{player.books.to_json},\"icon\":#{player.icon.to_json}}"
      end
    end

    describe NullPlayer do
      let(:null_player) { build(:null_player) }
      let(:null_player2) { build(:null_player) }

      it 'has a name and id stub to smooth some functionality in Game and Match' do
        expect { null_player.name }.not_to raise_exception
        expect { null_player.id }.not_to raise_exception
      end

      it 'calls eql two NullPlayers' do
        expect(null_player == null_player2).to be true
        expect(null_player.eql?(null_player2)).to be true
        expect(null_player.hash).to eq null_player2.hash
      end
    end
  end
end
