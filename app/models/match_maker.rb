class MatchMaker
  def match(user, number_of_players)
    pending_users[number_of_players] << user
  end

  def start_match(user)
    pending_users.each do |number_of_players, users|
      if users.include?(user) && users.length >= number_of_players
        match = Match.create(users: users.shift(number_of_players))
        match.game.deal
        match.save
        return match
      end
    end
    return nil
  end

  def pending_users
    @pending_users ||= Hash.new {|hash, key| hash[key] = []}
  end

  def is_holding(user)
    pending_users.values.flatten.include? user
  end

  def reset
    @pending_users = Hash.new {|hash, key| hash[key] = []}
  end
end
