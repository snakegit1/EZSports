class RemoveExtraLeagueColumns < ActiveRecord::Migration
  def change
  	remove_column :child_leagues, :user_id
  	remove_column :adult_leagues, :user_id
  end
end
