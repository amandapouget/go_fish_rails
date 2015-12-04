class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.boolean :over, default: false, null: false
      t.text :message
      t.integer :hand_size, default: 5
      t.text :game

      t.timestamps null: false
    end
  end
end
