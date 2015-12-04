class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.text :type
      t.integer :think_time

      t.timestamps null: false
    end
  end
end
