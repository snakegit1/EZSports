class AddCcidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cc_id, :integer
  end
end
