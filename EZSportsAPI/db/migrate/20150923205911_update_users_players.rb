class UpdateUsersPlayers < ActiveRecord::Migration
  def change
    #   remove a bunch of crap that belongs in players, not users
    remove_column :users, :phone
    remove_column :users, :birthday
    remove_column :users, :gender
    remove_column :users, :other_contacts
    remove_column :users, :ec_first1
    remove_column :users, :ec_last1
    remove_column :users, :ec_email1
    remove_column :users, :ec_phone1
    remove_column :users, :ec_first2
    remove_column :users, :ec_last2
    remove_column :users, :ec_email2
    remove_column :users, :ec_phone2
    remove_column :users, :active_season_id
    remove_column :users, :league_id

    # Adding the columns where they belong...the player
    add_column :players, :phone, :string
    add_column :players, :other_contacts, :string
    add_column :players, :ec_first1, :string
    add_column :players, :ec_last1, :string
    add_column :players, :ec_email1, :string
    add_column :players, :ec_phone1, :string
    add_column :players, :ec_first2, :string
    add_column :players, :ec_last2, :string
    add_column :players, :ec_email2, :string
    add_column :players, :ec_phone2, :string
    add_column :players, :active_season_id, :integer
    add_column :players, :league_id, :integer
  end
end
