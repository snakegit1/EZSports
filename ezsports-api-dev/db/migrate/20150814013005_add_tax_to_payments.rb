class AddTaxToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :tax, :decimal, precision: 8, scale: 2, default: 0
  end
end
