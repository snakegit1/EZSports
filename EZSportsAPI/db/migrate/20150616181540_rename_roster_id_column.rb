class RenameRosterIdColumn < ActiveRecord::Migration
  def change
  	rename_column :user_rosters, :roster_id, :team_active_seasons_id
  end
end
