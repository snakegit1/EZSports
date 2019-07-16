class LeaguesRemoveKey < ActiveRecord::Migration
  def change
      remove_column :leagues, :league_manager_key
  end
end
