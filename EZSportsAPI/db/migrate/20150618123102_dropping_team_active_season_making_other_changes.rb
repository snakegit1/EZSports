class DroppingTeamActiveSeasonMakingOtherChanges < ActiveRecord::Migration
  def change
  	drop_table :team_active_seasons
  	add_column :teams, :season_id, :integer
  	rename_column :user_rosters, :team_active_seasons_id, :team_id
  end
end
