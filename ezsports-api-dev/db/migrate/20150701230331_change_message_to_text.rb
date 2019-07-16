class ChangeMessageToText < ActiveRecord::Migration
  def change
    change_column :messages, :message, :text
  end
end
