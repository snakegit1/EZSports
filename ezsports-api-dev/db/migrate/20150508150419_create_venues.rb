class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
    	t.string :name
    	t.string :first
    	t.string :last
    	t.string :address_1
    	t.string :address_2
    	t.string :city
    	t.string :state
    	t.string :zip
    	t.string :phone
    	t.string :league_id
      	t.timestamps

    end
  end
end
