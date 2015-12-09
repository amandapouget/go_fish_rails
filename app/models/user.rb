class User < ActiveRecord::Base
  FAKENAMES = ["Marie", "Amanda", "Bob", "Charlie", "David", "Echo", "Frank", "Gertrude", "Helga", "Iggy", "Jaqueline", "Kevin", "Lillian", "Mike", "Naomi", "Olivier", "Patrick", "Quentin", "Rose"]

  has_many :participations
  has_many :matches, :through => :participations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def points
    self.participations.sum(:points)
  end
end
