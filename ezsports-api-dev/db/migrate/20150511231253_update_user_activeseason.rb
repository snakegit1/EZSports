class UpdateUserActiveseason < ActiveRecord::Migration
  def change
      add_column :users, :active_season_id, :int
  end
end
