class AddCcNumberToPayments < ActiveRecord::Migration
  def change
  	add_column :leagues, :cc_number, :BIGINT, limit: 16
  	add_column :leagues, :cvv_number, :integer
  	add_column :leagues, :exp_month, :integer
  	add_column :leagues, :exp_year, :integer
  end
end
