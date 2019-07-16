class FixingUsersAndKidsTables < ActiveRecord::Migration
  def change
  	add_column :users, :image, :string
  	add_column :users, :phone, :string
  	add_column :users, :birthday, :string
  	add_column :users, :gender, :string
  	add_column :users, :other_contacts, :string
  	
  	add_column :users, :ec_first1, :string
  	add_column :users, :ec_last1, :string
  	add_column :users, :ec_email1, :string
  	add_column :users, :ec_phone1, :string

  	add_column :users, :ec_first2, :string
  	add_column :users, :ec_last2, :string
  	add_column :users, :ec_email2, :string
  	add_column :users, :ec_phone2, :string

  	remove_column :kids, :other_contacts
  	add_column :kids, :image, :string

  end
end
