class AddExemptionNoToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :exemption_no, :string, null: true
  end
end
