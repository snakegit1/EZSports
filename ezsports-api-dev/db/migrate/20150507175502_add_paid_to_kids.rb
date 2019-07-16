class AddPaidToKids < ActiveRecord::Migration
  def change
  	add_column :kids, :paid, :boolean
  end
end
