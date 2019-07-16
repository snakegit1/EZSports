class CreateLeaguePlayers < ActiveRecord::Migration
  def change
    create_table :league_players do |t|
      t.integer :player_id
      t.integer :league_id

      t.timestamps
    end
  end
end
