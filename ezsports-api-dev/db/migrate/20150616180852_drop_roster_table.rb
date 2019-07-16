class DropRosterTable < ActiveRecord::Migration
  def change
  	drop_table :rosters
  end
end
