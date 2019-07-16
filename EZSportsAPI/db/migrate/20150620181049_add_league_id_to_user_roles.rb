class AddLeagueIdToUserRoles < ActiveRecord::Migration
  def change
  	add_column :user_roles, :league_id, :integer
  end
end
