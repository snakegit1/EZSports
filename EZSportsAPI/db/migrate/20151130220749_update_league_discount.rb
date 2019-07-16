class UpdateLeagueDiscount < ActiveRecord::Migration
  def change
  	add_column :leagues, :discount_code, :string
  end
end
