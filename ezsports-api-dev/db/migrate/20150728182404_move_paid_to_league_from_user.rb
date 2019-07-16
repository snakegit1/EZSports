class MovePaidToLeagueFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :paid 
    add_column :leagues, :paid, :boolean
  end
end
