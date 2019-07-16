class UpdateScheduleType < ActiveRecord::Migration
  def change
  	add_column :game_schedules, :type, :string
  end
end
