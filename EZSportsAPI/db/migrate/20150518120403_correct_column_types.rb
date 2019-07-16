class CorrectColumnTypes < ActiveRecord::Migration
  def change
  	change_column :adult_leagues, :league_id, 'integer USING CAST("league_id" AS integer)'
  	change_column :child_leagues, :league_id, 'integer USING CAST("league_id" AS integer)'
  	change_column :kids, :parent_id, 'integer USING CAST("parent_id" AS integer)'
  	change_column :users, :league_id, 'integer USING CAST("league_id" AS integer)'
  	change_column :venues, :league_id, 'integer USING CAST("league_id" AS integer)'
  end
end
