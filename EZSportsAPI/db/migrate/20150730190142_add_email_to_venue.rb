class AddEmailToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :email, :string
  end
end
