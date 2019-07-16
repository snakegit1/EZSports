class DropCoachRostersOtherFixes < ActiveRecord::Migration
  def change
  	drop_table :coach_roster
  	# drop_table :coaches
  	rename_table :user_rosters, :team_rosters
  	remove_column :teams, :coach_id
  end
end
