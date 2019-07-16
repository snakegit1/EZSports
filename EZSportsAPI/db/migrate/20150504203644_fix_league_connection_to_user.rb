class FixLeagueConnectionToUser < ActiveRecord::Migration
  def change
  	remove_column :leagues, :user_api_key
  	add_column :users, :league_id, :integer
  end
end
