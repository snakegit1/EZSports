class UpdateScheduleScheduleType < ActiveRecord::Migration
  def change
  	remove_column :game_schedules, :type
  	add_column :game_schedules, :schedule_type, :string
  end
end
