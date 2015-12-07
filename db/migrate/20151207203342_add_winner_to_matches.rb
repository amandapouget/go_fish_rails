class AddWinnerToMatches < ActiveRecord::Migration
  def change
    change_table :matches do |table|
      table.integer :winner_id
    end
  end
end
