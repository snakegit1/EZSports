class AddUserToLeague < ActiveRecord::Migration
  def change
  	add_column :leagues, :user_api_key, :string
  	add_column :leagues, :image, :string
  end
end
