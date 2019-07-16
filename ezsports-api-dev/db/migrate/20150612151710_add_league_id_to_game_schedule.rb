class AddLeagueIdToGameSchedule < ActiveRecord::Migration
  def change
  	add_column :game_schedules, :league_id, :integer
  end
end
