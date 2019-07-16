class UpdateSeasonTeamsize < ActiveRecord::Migration
  def change
      add_column :seasons, :team_size, :int
  end
end
