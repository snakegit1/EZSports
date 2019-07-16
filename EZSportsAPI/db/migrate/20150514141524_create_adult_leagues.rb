class CreateAdultLeagues < ActiveRecord::Migration
  def change
    create_table :adult_leagues do |t|
      t.string :adult_id
      t.string :league_id

      t.timestamps
    end
  end
end
