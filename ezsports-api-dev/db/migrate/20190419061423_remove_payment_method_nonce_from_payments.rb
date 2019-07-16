class RemovePaymentMethodNonceFromPayments < ActiveRecord::Migration
  def change
  	remove_column :payments, :payment_method_nonce, :string
  	# remove_column :payments, :card_number, :BIGINT, limit: 16
  end
end
