class RenameMessageTableColumn < ActiveRecord::Migration
  def change
  	rename_column :messages, :user_to, :player_to
  end
end
