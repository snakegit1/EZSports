require 'sendgrid-ruby'

class User < ActiveRecord::Base
	has_secure_password
	has_many :adult_leagues
	has_many :user_roles
	has_many :roles, through: :user_roles
	has_one :league
	has_many :team_rosters
	has_one :credit_card

	validates_presence_of :first, :last, :email, :password

	def self.search(search)
		if search
			where('lower(first) LIKE :searchterm OR lower(last) LIKE :searchterm OR lower(email) LIKE :searchterm', searchterm: "%#{search.downcase}%")
		else
			all
		end
	end

end
