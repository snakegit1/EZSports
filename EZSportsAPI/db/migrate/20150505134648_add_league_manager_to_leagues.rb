class AddLeagueManagerToLeagues < ActiveRecord::Migration
  def change
  	add_column :leagues, :league_manager_key, :string
  end
end
