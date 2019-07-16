class UpdateTeamLeague < ActiveRecord::Migration
  def change
      add_column :teams, :league_id, :int
  end
end
