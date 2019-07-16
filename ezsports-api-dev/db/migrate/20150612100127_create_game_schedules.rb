class CreateGameSchedules < ActiveRecord::Migration
  def change
    create_table :game_schedules do |t|
      t.integer :home_id
      t.integer :away_id
      t.integer :venue_id
      t.datetime :time

      t.timestamps
    end
  end
end
