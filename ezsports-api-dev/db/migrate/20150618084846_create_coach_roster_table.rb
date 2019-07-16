class CreateCoachRosterTable < ActiveRecord::Migration
  def change
    create_table :coach_roster do |t|
      t.integer :user_id
      t.string :team_active_seasons_id
    end
  end
end
