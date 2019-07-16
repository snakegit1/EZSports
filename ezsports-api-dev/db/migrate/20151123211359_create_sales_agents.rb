class CreateSalesAgents < ActiveRecord::Migration
  def change
    create_table :sales_agents do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :zipcodes

      t.timestamps null: false
    end
  end
end
