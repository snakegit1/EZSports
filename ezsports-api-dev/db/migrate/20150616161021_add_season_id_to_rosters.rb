class AddSeasonIdToRosters < ActiveRecord::Migration
  def change
  	add_column :rosters, :season_id, :integer
  end
end
