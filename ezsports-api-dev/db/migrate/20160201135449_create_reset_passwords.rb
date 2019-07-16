class CreateResetPasswords < ActiveRecord::Migration
  def change
    create_table :reset_passwords do |t|
      t.integer :user_id
      t.string :key

      t.timestamps null: false
    end
  end
end
