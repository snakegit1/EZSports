class ChangeTeamSeasonidLeagueid < ActiveRecord::Migration
  def change
    rename_column :teams, :season_id, :league_id
  end
end
