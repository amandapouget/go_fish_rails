class AddPointsToParticipation < ActiveRecord::Migration
  def change
    change_table :participations do |table|
      table.integer :points, default: 0
    end
  end
end
