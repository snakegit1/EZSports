class AddReferenceToKidsForLeagues < ActiveRecord::Migration
  def change
  	add_reference :child_leagues, :kid, index: true
  end
end
