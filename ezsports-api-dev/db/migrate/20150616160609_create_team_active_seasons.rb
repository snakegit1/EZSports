class CreateTeamActiveSeasons < ActiveRecord::Migration
  def change
    create_table :team_active_seasons do |t|
      t.integer :team_id
      t.integer :season_id
      t.boolean :is_active

      t.timestamps
    end
  end
end
