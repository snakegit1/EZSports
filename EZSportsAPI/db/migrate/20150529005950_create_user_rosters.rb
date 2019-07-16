class CreateUserRosters < ActiveRecord::Migration
  def change
    create_table :user_rosters do |t|
      t.integer :user_id
      t.integer :roster_id

      t.timestamps
    end
  end
end
