class User < ActiveRecord::Base
  FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian", "Mike", "Naomi", "Olivier", "Patrick", "Quentin", "Rose"]

  has_many :participations
  has_many :matches, :through => :participations

  def current_match
    unfinished_matches = matches.select { |match| match.over? == false }
    unfinished_matches.sort_by { |match| match.updated_at }.last
  end

  def points
    total = 0
    Participation.find do |participation|
      total += participation.points if participation.user.id == self.id # the death trap of STI
    end
    total
  end
end
