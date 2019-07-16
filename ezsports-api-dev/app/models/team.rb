class Team < ActiveRecord::Base
	has_one :roster
  has_many :seasons, :class_name => "TeamActiveSeason", :foreign_key => "team_id"
end
