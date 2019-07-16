class ChangeIsActiveOnPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :is_active
    add_column :players, :season_id, :integer
  end
end
