class UpdateTeamSeason < ActiveRecord::Migration
  def change
      add_column :teams, :season_id, :int
  end
end
