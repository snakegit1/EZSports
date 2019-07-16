class CreateLeagueManagers < ActiveRecord::Migration
  def change
    create_table :league_managers do |t|
      t.integer :user_id
      t.integer :active_league_id
      t.integer :league_id

      t.timestamps null: false
    end
  end
end
