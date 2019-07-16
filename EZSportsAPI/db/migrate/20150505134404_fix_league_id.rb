class FixLeagueId < ActiveRecord::Migration
  def change
  	remove_column :users, :league_id
  	add_column :users, :league_id, :string
  end
end
