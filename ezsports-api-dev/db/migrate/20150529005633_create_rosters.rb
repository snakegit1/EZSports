class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.integer :team_id
      t.integer :coach_id

      t.timestamps
    end
  end
end
