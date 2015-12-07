class Participation < ActiveRecord::Base
  belongs_to :match
  belongs_to :user

  def user
    User.find(user_id)
  end

  def match
    Match.find(match_id)
  end

  def self.find_by_match_and_user(match, user)
    self.find { |participation| (participation.match == match) && (participation.user == user) }
  end

  def self.set_points(match)
    participation = self.find_by_match_and_user(match, match.winner)
    participation.set_points(1)
    participation.save # I genuinely don't see why this would be better placed elsewhere.
  end

  def set_points(integer)
    self.points = integer # * tournament.weight, for example
  end
end
