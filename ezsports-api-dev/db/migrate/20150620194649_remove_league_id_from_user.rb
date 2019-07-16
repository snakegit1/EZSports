class RemoveLeagueIdFromUser < ActiveRecord::Migration
  def change
  	remove_column :users, :league_id 
  end
end
