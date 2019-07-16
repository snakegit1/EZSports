class ChangePlayerColumnInMessages < ActiveRecord::Migration
  def change
    rename_column :messages, :player_to, :user_to
  end
end
