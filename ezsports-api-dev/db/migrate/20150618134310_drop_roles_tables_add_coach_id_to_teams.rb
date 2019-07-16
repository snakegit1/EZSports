class DropRolesTablesAddCoachIdToTeams < ActiveRecord::Migration
  def change
  	drop_table :roles
  	drop_table :user_roles
  	add_column :teams, :coach_id, :integer
  end
end
