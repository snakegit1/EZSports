class CreateUserRolesTable < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.integer :role_id
      t.integer :user_id
    end
  end
end
