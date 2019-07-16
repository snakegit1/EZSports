class CreateChildLeagues < ActiveRecord::Migration
  def change
    create_table :child_leagues do |t|
      t.string :child_id
      t.string :league_id

      t.timestamps
    end
  end
end
