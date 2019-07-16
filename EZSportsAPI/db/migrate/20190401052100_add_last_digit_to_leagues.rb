class AddLastDigitToLeagues < ActiveRecord::Migration
  def change
  	add_column :leagues, :last_digit, :integer
  end
end
