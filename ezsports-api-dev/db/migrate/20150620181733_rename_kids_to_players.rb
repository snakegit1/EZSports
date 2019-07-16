class RenameKidsToPlayers < ActiveRecord::Migration
  def change
  	rename_table :kids, :players
  end
end
