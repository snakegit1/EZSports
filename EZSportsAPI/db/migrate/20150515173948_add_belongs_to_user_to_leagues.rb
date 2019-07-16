class AddBelongsToUserToLeagues < ActiveRecord::Migration
  def change
  	add_reference :child_leagues, :users, index: true
  	add_reference :adult_leagues, :users, index: true
  end
end
