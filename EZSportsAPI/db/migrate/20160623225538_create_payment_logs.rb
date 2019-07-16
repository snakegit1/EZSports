class CreatePaymentLogs < ActiveRecord::Migration
  def change
    create_table :payment_logs do |t|
      t.integer :league_id
      t.datetime :process_date
      t.decimal :amount, :precision => 6, :scale => 2
      t.timestamps null: false
    end
  end
end
