class CreateKids < ActiveRecord::Migration
  def change
    create_table :kids do |t|
      t.string :first
      t.string :last
      t.string :gender
      t.string :birthday
      t.string :parent_id
      t.string :other_contacts
      t.timestamps
    end
  end
end
