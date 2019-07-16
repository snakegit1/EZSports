class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.references :user, index: true, foreign_key: true
      t.string :last_4
      t.string :customer_id
      t.string :token
    end
  end
end
