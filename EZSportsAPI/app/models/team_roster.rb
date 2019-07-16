class TeamRoster < ActiveRecord::Base
	belongs_to :user
	belongs_to :roster
end
