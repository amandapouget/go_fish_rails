class User < ActiveRecord::Base
  FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian", "Mike", "Naomi", "Olivier", "Patrick", "Quentin", "Rose"]

  has_many :participations
  has_many :matches, :through => :participations

  def points
    self.participations.sum(:points)
  end
end
