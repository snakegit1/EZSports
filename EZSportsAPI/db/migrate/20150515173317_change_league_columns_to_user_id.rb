class ChangeLeagueColumnsToUserId < ActiveRecord::Migration
  def change
  	rename_column :adult_leagues, :adult_id, :user_id
  	rename_column :child_leagues, :child_id, :user_id
  end
end
