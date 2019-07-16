class DropChildAdultLeagueTables < ActiveRecord::Migration
  def change
  	drop_table :child_leagues
  	drop_table :adult_leagues
  end
end
