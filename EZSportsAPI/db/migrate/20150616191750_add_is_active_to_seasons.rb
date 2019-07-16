class AddIsActiveToSeasons < ActiveRecord::Migration
  def change
  	add_column :seasons, :is_active, :boolean
  end
end
