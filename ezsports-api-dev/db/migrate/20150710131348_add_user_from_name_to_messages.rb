class AddUserFromNameToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :from_user_name, :string
  end
end
