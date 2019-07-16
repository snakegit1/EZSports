class AddCcIdToLeagues < ActiveRecord::Migration
  def change
  	add_column :leagues, :cc_id, :integer
  	add_column :leagues, :cc_token, :string
  end
end
