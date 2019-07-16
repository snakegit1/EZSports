class FixingKidsTableReferences < ActiveRecord::Migration
  def change
  	remove_reference :child_leagues, :user, index: true


  end
end
