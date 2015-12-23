class MatchMaker
  @@mutex = Mutex.new

  def match(user, number_of_players)
    pending_users[number_of_players] << user
  end

  def start_match_thread(user, seconds = 5)
    sleep seconds
    @@mutex.synchronize {
      return start_match(user) || start_match(user, robots: true)
    }
  end

  def start_match(user, robots: false)
    number_of_players = queue_number(user) || return
    add_robots(number_of_players) if robots
    return create_match(number_of_players) if pending_users[number_of_players].length >= number_of_players
  end

  def pending_users
    @pending_users ||= Hash.new {|hash, key| hash[key] = []}
  end

  def is_holding?(user)
    pending_users.values.flatten.include? user
  end

  def reset
    @pending_users = Hash.new {|hash, key| hash[key] = []}
  end

  private
    def queue_number(user)
      pending_users.each { |key, value| return key if value.include?(user) }
      return nil
    end

    def add_robots(number_of_players)
      match(RobotUser.create, number_of_players) until pending_users[number_of_players].length == number_of_players
    end

    def create_match(number_of_players)
      match = Match.create(users: pending_users[number_of_players].shift(number_of_players))
      match.game.deal
      match.save! and return match
    end
end
