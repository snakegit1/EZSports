class RenameLeagueManager < ActiveRecord::Migration
  def change
      rename_column :league_managers, :league_id, :active_season_id
  end
end
