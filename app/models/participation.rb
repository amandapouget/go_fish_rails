class Participation < ActiveRecord::Base
  attr_accessor :match_id, :user_id
  belongs_to :match
  belongs_to :user
end
