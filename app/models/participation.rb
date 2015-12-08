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
    Participation.find_by(match_id: match.id, user_id: user.id)
  end
end
