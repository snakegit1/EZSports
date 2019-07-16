class ChangeUserIdNamesOnLeagues < ActiveRecord::Migration
  def change
  	rename_column :adult_leagues, :users_id, :user_id
  	rename_column :child_leagues, :users_id, :user_id
  end
end
