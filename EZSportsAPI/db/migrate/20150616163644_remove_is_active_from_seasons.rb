class RemoveIsActiveFromSeasons < ActiveRecord::Migration
  def change
  	remove_column :seasons, :is_active
  end
end
