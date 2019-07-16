class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :name
      t.string :zip
      t.string :age
      t.string :sport

      t.timestamps
    end
  end
end
