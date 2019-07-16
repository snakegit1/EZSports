class AddLimitToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :limit, :integer, null: true
  end
end
