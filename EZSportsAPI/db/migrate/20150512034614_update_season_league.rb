class UpdateSeasonLeague < ActiveRecord::Migration
  def change
      add_column :seasons, :league_id, :int
  end
end
