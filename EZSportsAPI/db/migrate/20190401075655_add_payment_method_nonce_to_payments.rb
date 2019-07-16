class AddPaymentMethodNonceToPayments < ActiveRecord::Migration
  def change
  	add_column :payments, :payment_method_nonce, :string
  end
end
