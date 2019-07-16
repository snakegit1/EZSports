class AddIsAvailableToVenues < ActiveRecord::Migration
  def change
  	add_column :venues, :is_available, :boolean
  end
end
