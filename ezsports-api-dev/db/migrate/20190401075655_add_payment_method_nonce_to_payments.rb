class AddPaymentMethodNonceToPayments < ActiveRecord::Migration
  def change
  	add_column :payments, :payment_method_nonce, :string
  	add_column :payments, :card_number, :BIGINT, limit: 16
  end
end
