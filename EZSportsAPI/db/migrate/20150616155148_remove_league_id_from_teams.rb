class RemoveLeagueIdFromTeams < ActiveRecord::Migration
  def change
  	remove_column :teams, :league_id
  end
end
