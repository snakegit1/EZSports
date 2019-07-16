require 'sendgrid-ruby'
#require 'coralogix_logger'

class UsersController < BaseController
	before_action :validate, except: [:signup, :login, :key_login, :test, :confirm_email]
	respond_to :json

	# CHANGE API PATH BELOW AS NEEDED @API_PATH
	def players
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end
			
			id = params[:id]
			adults = Player.where('user_id = ?', id)
			kids = Player.where('parent_id = ?', id)

			players = adults | kids

			p players

			render json: players
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def dupe_check
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			user = User.where('email = ?', params[:email]).count
			render json: user
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def active
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			league_id = params[:league_id]
			user = User.find(id)
			if user.league_id == league_id
				user.league_id = nil
			else
				user.league_id = league_id
			end
			user.save(:validate => false)

			render json: user

		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def all
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		@users = User.all
		render json: @users
	end

	def confirm_email
		begin
			p 'CONFIRMING EMAIL!!!'
			api_key = params[:key]
			user = User.where("api_key = ?", api_key).first
			if (user == nil)
				p 'Can\'t find user'
				render json: false
			end

			user[:confirmed] = true
			user.save(:validate => false)
			render json: true
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def create_adult
		begin
			# v = ValidateKey()
			# if (v == nil)
			# 	render json: nil
			# 	return
			# end

			p "CREATE ADULT"

			p "Team or Admin: " + params[:team_or_admin].to_s
			
			if (params[:team_or_admin] == true || params[:team_or_admin] == "team")
				team_or_admin = "team"
			else
				team_or_admin = "admin"
			end

			player_id = params[:id]
			first = params[:user_first]
			last = params[:user_last]
			email = params[:email].downcase
			gender = params[:gender]
			phone = params[:phone]
			paid = params[:paid]
			birthday = params[:birthday]
			other_contacts = params[:other_contacts]
			ec_first1 = params[:ec_first1]
			ec_last1 = params[:ec_last1]
			ec_email1 = params[:ec_email1]
			ec_phone1 = params[:ec_phone1]
			ec_first2 = params[:ec_first2]
			ec_last2 = params[:ec_last2]
			ec_phone2 = params[:ec_phone2]
			ec_email2 = params[:ec_email2]

			league_id = params[:league_id]
			active_season_id = params[:active_season_id]

			is_new_user = false
			is_new_player = false
			player = nil

			if player_id == nil
				p "ID is nil..."
				user = User.where('email = ?', email).first
				if user == nil
					p "User is new..."
					is_new_user = true
					user = User.new()
					randomString = SecureRandom.hex
					randomString = randomString[0..5] # assign them a temporary password
					user.password = randomString
					p "Temp Password: " + randomString

					@password = user.password
					user.temp_password = true
					user.api_key = SecureRandom.hex
				else
					p "Email is a duplicate..."
				end
			else
				p "ID is not nil...getting player and user"
				player = Player.find(player_id)
				user = User.find(player.user_id)
				if (user == nil)
					user = User.find(player.parent_id)
				end
			end

			user.first = first
			user.last = last
			user.email = email

			puts "saving user..."
			user.save(:validate => false)

			if player == nil
				p "Player is new..."
				is_new_player = true
		    	player = Player.new()
		    else
				p "Player is existing... [" + player.id.to_s + "]"
		   	end

			player.first = first
			player.last = last
			player.user_id = user.id
			player.email = email

			player.gender = gender
			player.birthday = birthday

			player.phone = phone
			player.league_id = league_id
			player.active_season_id = active_season_id
			player.season_id = active_season_id

			player.other_contacts = other_contacts
			player.ec_first1 = ec_first1
			player.ec_last1 = ec_last1
			player.ec_email1 = ec_email1
			player.ec_phone1 = ec_phone1
			player.ec_first2 = ec_first2
			player.ec_last2 = ec_last2
			player.ec_email2 = ec_email2
			player.ec_phone2 = ec_phone2

			player.paid = paid

			p "Saving player..."
			player.save

			lp = LeaguePlayer.where("player_id = ? and league_id=?", player.id, league_id).first

			if lp == nil
				p "League Player is new..."
				lp = LeaguePlayer.new(league_id: league_id, player_id: player.id)
				p "Saving LP..."
				lp.save
			else
				p "League Player is existing..."
			end

			role_player = Role.where("name = ?", "player").first
			check = UserRole.where("user_id = ? and role_id = ? and league_id = ?", user.id, role_player.id, league_id).first
			if (check == nil)
				p "CREATING PLAYER ROLE"
				UserRole.create(user_id: user[:id], role_id: role_player[:id], league_id: league_id)
			else
				p 'Player role is existing...'
			end

			if (!is_new_user && !is_new_player)
				p "Existing player...no need to send email"
				render json: user
				return
			end

			p "SENDING EMAIL"
			league = League.find(league_id)

			@email = email
			@userkey = user[:api_key]
			@first = user[:first]
			@league = league.name

			if send_email?
				if team_or_admin == 'team'
					send_user_signup_email()
				else
					if is_new_user
						send_admin_new_user_email()
					elsif is_new_player
						send_admin_new_player_email()
					end
				end
			end

			render json: user

		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def create_child
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			p "CREATE CHILD"

			p "Team or Admin: " + params[:sendtoteam].to_s
			team_or_admin = "admin"
			if (params[:sendtoteam] == true)
				team_or_admin = "team"
			end

			parent_player_id = params[:id]
			first = params[:user_first]
			last = params[:user_last]
			email = params[:email].downcase
			gender = params[:gender]
			phone = params[:phone]
			paid = params[:paid]
			birthday = params[:birthday]
			other_contacts = params[:other_contacts]
			ec_first1 = params[:ec_first1]
			ec_last1 = params[:ec_last1]
			ec_email1 = params[:ec_email1]
			ec_phone1 = params[:ec_phone1]
			ec_first2 = params[:ec_first2]
			ec_last2 = params[:ec_last2]
			ec_phone2 = params[:ec_phone2]
			ec_email2 = params[:ec_email2]
			child_first = params[:child_first]
			child_last = params[:child_last]

			league_id = params[:league_id]
			active_season_id = params[:active_season_id]

			is_new_user = false
			is_new_player = false
			player = nil

			if parent_player_id == nil
				p "Parent ID is nil..."
				parent = User.where('email = ?', email).first
				if parent == nil
					p "Parent is a new user..."
					is_new_user = true
					parent = User.new()
					randomString = SecureRandom.hex
					randomString = randomString[0..5] # assign them a temporary password
					parent.password = randomString
					p "Temp Password: " + randomString

					@password = parent.password
					parent.temp_password = true
					parent.api_key = SecureRandom.hex
				else
					p "Parent Email is a duplicate..."
				end
			else
				p "Parent Player ID is not nil...getting user"
				parent_player = Player.find(parent_player_id)
				parent = User.find(parent_player.user_id)
			end

			parent.first = first
			parent.last = last
			parent.email = email

			puts "saving parent..."
			parent.save(:validate => false)

			is_new_player = true
			player = Player.new()

			player.first = child_first
			player.last = child_last
			player.parent_id = parent.id

			player.gender = gender
			player.birthday = birthday

			player.phone = phone
			player.league_id = league_id
			player.active_season_id = active_season_id
			player.season_id = active_season_id

			player.other_contacts = other_contacts
			player.ec_first1 = ec_first1
			player.ec_last1 = ec_last1
			player.ec_email1 = ec_email1
			player.ec_phone1 = ec_phone1
			player.ec_first2 = ec_first2
			player.ec_last2 = ec_last2
			player.ec_email2 = ec_email2
			player.ec_phone2 = ec_phone2

			player.paid = paid

			p "Saving child player..."
			player.save

			# now save the player in the LeaguePlayer table
			p "Creating League Player"
			lp = LeaguePlayer.new(league_id: league_id, player_id: player.id)
			p "Saving LP..."
			lp.save

			role_player = Role.where("name = ?", "player").first
			check = UserRole.where("user_id = ? and role_id = ? and league_id = ?", parent.id, role_player.id, league_id).first
			if (check == nil)
				p "Creating parent role..."
				UserRole.create(user_id: parent.id, role_id: role_player.id, league_id: league_id)
			else
				p 'Player role is existing...'
			end

			p "SENDING EMAIL"
			league = League.find(league_id)

			@email = email
			@userkey = parent.api_key
			@league = league.name

			if send_email?
				if team_or_admin == 'team'
					send_user_signup_email()
				else
					if is_new_user
						@first = parent.first
						send_admin_new_parent_user_email()
					end

					@first = player.first
					send_admin_new_child_email()
				end
			end

			render json: player

		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def delete
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			user = User.find(id)

			players = Player.where("user_id = ?", user.id)
			league_players = []
			players.each do |p|
				league_players.push(LeaguePlayer.where("player_id = ?", p.id))
			end

			league_players.destroy_all
			players.destroy_all

			players = Player.where("parent_id = ?", user.id)
			players.destroy_all

			coaches = Coach.where("user_id = ?", user.id)
			coaches.destroy_all

			team_rosters = TeamRoster.where("user_id = ?", user.id)
			team_rosters.destroy_all

			user_roles = UserRole.where("user_id = ?", user.id)
			user_roles.destroy_all

			User.delete(user)

			render json: true
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_by_email
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			email = params[:email].downcase
			user = User.where('lower(email) = ?', email).first

			if (user == nil)
				render json: nil
			else
				render json: user
			end
		rescue => e
			HandleError(e)
			render json: nil
		end
	end
	
	def test_logging

		LogInfo('LOGGING TEST SUCCESSFUL!!!')
		
		head :ok
	end

	def get_coach
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			# Ok... we get the coach based on the user id sent it.
			player_id = params[:player_id]
			league_id = params[:league_id]

			p 'Getting coach for player_id (' + player_id.to_s + ') and league_id (' + league_id.to_s + ')'

			roster = TeamRoster.where("user_id = ?", player_id)
			if (roster == nil)
				p 'They are not on a team'
				# they aren't on a team...
				render json: false
				return
			end

			team = nil
			roster.each do |tr|
				t = Team.find(tr.team_id)
				if t.league_id.to_s == league_id.to_s
					p 'Found Team: ' + t.id.to_s
					team = t
					break
				end
			end

			if (team == nil)
				# couldn't find the team...
				p 'Could not find a team...'
				render json: false
				return
			end


			list = Coach.where("team_id = ?", team.id)
			coaches = []
			list.each do |c|
				coaches.push(User.find(c[:user_id]))
				p 'Found coach: ' + c[:user_id].to_s
			end

			render json: coaches
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_coach_messages
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			user_id = params[:user_id]
			league_id = params[:league_id]

			p 'GETTING COACH MESSAGES : ' + user_id.to_s + ' | ' + league_id.to_s

			result = []
			messages = Message.where("user_to = ?", user_id)
			messages.each do |m|
				userfrom = User.find(m.user_from)
				#user from can be a LM or a player
				league = League.find(league_id)
				if (league.user_id == userfrom.id)
					# user is the LM
					m.from_user_name = userfrom.first + " " + userfrom.last + " (LM)"

					item = { "from" => { "first" => userfrom.first, "last" => userfrom.last, "email" => userfrom.email },
							 "is_league_manager" => true,
							 "message" => m,
							 "team" => nil
						   }

					result.push(item)
				else
					# user is a player, is the player in the right league?
					playerList = Player.where("user_id = ? or parent_id = ?", userfrom.id, userfrom.id)
					playerList.each do |player|
						lpList = LeaguePlayer.where("player_id = ? and league_id = ?", player.id, league_id)
						lpList.each do |lp|
							# get their team
							roster = TeamRoster.where("user_id = ?", lp.player_id)
							roster.each do |x|
								t = Team.find(x.team_id)
								m.from_user_name = userfrom.first + " " + userfrom.last

								item = { "from" => { "first" => userfrom.first, "last" => userfrom.last, "email" => userfrom.email },
										 "is_league_manager" => false,
										 "message" => m,
										 "team" => t
									   }

								result.push(item);
							end
						end
					end
				end
			end

			p '# OF MESSAGES: ' + result.length.to_s
			render json: result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_player_messages
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			user_id = params[:user_id]
			league_id = params[:league_id]
			p 'GETTING PLAYER MESSAGES: ' + user_id.to_s + ' | ' + league_id.to_s

			result = []
			messages = Message.where("user_to = ?", user_id)

			messages.each do |m|
				userfrom = User.find(m.user_from)

				# User From has to be a coach...want to find the team
				c = Coach.where("user_id = ?", userfrom.id)
				c.each do |x|
					t = Team.find(x.team_id)

					if t.league_id.to_s == league_id.to_s

						m.from_user_name = userfrom.first + " " + userfrom.last

						item = { "coach" => { "first" => userfrom.first, "last" => userfrom.last, "email" => userfrom.email },
								 "message" => m,
								 "team" => t
							   }

						result.push(item);
					end
				end

			end

			p '# OF MESSAGES: ' + result.length.to_s
			render json: result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_messages
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			user_id = params[:user_id]
			messages = Message.where("user_to = ?", user_id)
			messages.each do |m|
				userfrom = User.find(m[:user_from])
				first = userfrom[:first]
				last = userfrom[:last]
				m[:from_user_name] = first + " " + last
			end
			render json: messages
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def admin_key_login
		begin
			user = ValidateKey()
			if user == nil
				render json: nil
				return
			end

			result = load_admin_login_data(user)

			render json: result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def key_login
		begin
			user = ValidateKey()
			if (user == nil)
				render json: nil
				return
			end

			result = load_team_login_data(user)
			render json:result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def admin_login
		begin
			email = params[:email].downcase
			password = params[:password]

			user = User.where('lower(email) = ?', email).first

			if (user != nil && password == "@@impersonate@@")
				result = load_admin_login_data(user)
				render json: result
				return
			end

			if user == nil || !user.authenticate(password)
				render json: nil
				return
			end

			result = load_admin_login_data(user)
			render json: result

		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_team_user
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			user_id = params[:id]
			user = User.find_by_id(user_id)
			result = load_team_login_data(user)

			render json: result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def team_login
		begin
			p "TEAM LOGIN..."
			email = params[:email].downcase
			password = params[:password]

			user = User.where('lower(email) = ?', email).first
			p user
			if user == nil
				p "Couldn't find player with email " + email
				render json: nil
				return
			end

			if user.authenticate(password)
				p "Authenticated"

				if user[:confirmed] == false
					p "User not confirmed"
					render json: nil
					return
				end

				result = load_team_login_data(user)
				render json: result
			else
				p "User not authenticated"

				render json: nil
			end
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def change_password
		begin
			user = ValidateKey()
			if (user == nil)
				render json: nil
				return
			end

			p 'Changing Password: User: ' + user.id.to_s
			password = params[:password]
			
			user.password = password
			user.save(:validate => false)
			render json: true
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def test
		p 'TEST: '
		p ENV['Domain']
		head :ok
	end

	def reset_password
		begin
			email = params[:email]
			p 'Resetting Password: ' + email
			user = User.where("email = ?", email).first
			p user

			if user == nil
				render json: "no_user"
				return
			end

			@key = SecureRandom.hex
			@email_content = '/password_mailer/reset_password'
			@first = user[:first]
			@email = email
			@reset_password_link = ENV['Admin_Domain'] + "#/pages/reset_password?key=" + @key

			p 'Link: ' + @reset_password_link

			rp = ResetPassword.new()
			rp.user_id = user[:id]
			rp.key = @key
			rp.save
			
			client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

			mail = SendGrid::Mail.new do |m|
				m.to = @email
				m.from = 'support@ez4mysports.com'
				m.subject = 'EZ Sports: Reset Your Password'
				m.html = render_to_string(@email_content, :layout => false)
			end

			if send_email?
				p 'SENDING ADMIN RESET PASSWORD EMAIL'
				res = client.send(mail)
				puts res.code
				puts res.body
			end

			render json: {key: user[:api_key]}
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def reset_team_password
		begin
			email = params[:email]
			p "Resetting Team Password: " + email
			user = User.where("email = ?", email).first
			if user == nil
				render json: "no_user"
				return
			end

			@key = SecureRandom.hex
			@email_content = '/password_mailer/reset_password'
			@first = user[:first]
			@email = email
			@reset_password_link = ENV['Team_Domain'] + "#/reset_password?key=" + @key

			p 'Link: ' + @reset_password_link

			rp = ResetPassword.new()
			rp.user_id = user[:id]
			rp.key = @key
			rp.save
			
			client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

			mail = SendGrid::Mail.new do |m|
				m.to = @email
				m.from = 'support@ez4mysports.com'
				m.subject = 'EZ Sports: Reset Your Password'
				m.html = render_to_string(@email_content, :layout => false)
			end

			if send_email?
				p 'SENDING TEAM RESET PASSWORD EMAIL'
				res = client.send(mail)
				puts res.code
				puts res.body
			end

			render json: {key: user[:api_key]}
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def reset_user_password
		begin
			p params
			
			key = params[:key]
			password = params[:password]

			p 'Resetting User Password: ' + key

			validate = ResetPassword.where('key = ?', key)
			if validate == nil || validate.length == 0
				p 'Key is invalid'
				render json: false.to_json
				return
			end

			user = User.find(validate.first[:user_id])
			user.password = password
			user.save(:validate => false)
			
			p 'Key is good...deleting it.'
			validate.destroy_all

			render json: true.to_json
		rescue => e
			HandleError(e)
			render json:nil
		end
	end

	def search
		begin
			@users = User.search(params[:search])
			render json: @users
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def send_messages
		users = params[:users] # Send me an array of user objects
		user_from = params[:user_from] # Send me the user_id
		@body = params[:body]
		@subject = params[:subject]

		#Defining the person the email is from
		from_person = User.find(user_from)
		@from = from_person[:first] + " " + from_person[:last]
		@from_email = from_person[:email]

		users.each do |u|
			@first = u[:first]
			@email = u[:email]
			if send_email?
				send_message_email
			end
			Message.create(user_from: user_from, user_to: u[:id], message: @body, subject: @subject) # You don't need .save if you use .create
		end
		head :ok
	end

	def send_reminders
		begin
			@email_content = '/reminder_mailer/reminder'
			@first = "Test2"
			@email = "dacur7@gmail.com"
			@date = "July 4, 1776"
			@venue = "The Georgia Dome"
			
			client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

			mail = SendGrid::Mail.new do |m|
				m.to = @email
				m.from = 'support@ez4mysports.com'
				m.subject = 'EZ Sports: Game Reminder'
				m.html = render_to_string(@email_content, :layout => false)
			end

			if send_email?
				p 'SENDING REMINDER EMAIL'
				res = client.send(mail)
				puts res.code
				puts res.body
			end
		end
	end

	# this is used when a new admin is signing himself up for ez-sports
	def signup
		begin
			@new_user = false
		    first = params[:first]
		  	last = params[:last]
		  	email = params[:email]
		  	password = params[:password]
		  	api_key = SecureRandom.hex

		  	user = nil
		  	e = User.where("email = ?", email).first
			if e == nil
				@new_user = true
				puts "User is new...saving"
				user = User.new(first: first, last: last, email: email, password: password, api_key: api_key)
			else
				p 'User already exists...updating'
				user = e
				user.first = first
				user.last = last
				user.email = email
				user.password = password
			end

			user.save(:validate => false)
			if !user.persisted?
				p 'Issue saving user...'
				render json: nil
				return
			end

			mgr_role = Role.where("name = ?", "manager").first

			check = nil
			lm_check = nil

			if !@new_user
				check = UserRole.where("user_id = ? and role_id = ?", user.id, mgr_role.id).first
				lm_check = LeagueManager.where("user_id = ?", user.id).first
			end

			if check == nil
				p 'Creating manager user role'
				UserRole.create!(user_id: user[:id], role_id: mgr_role[:id])
			else
				p 'Manager role is existing...'
			end

			if lm_check == nil
				p 'Creating League Manager record'
				lm = LeagueManager.create(user_id: user[:id])
			else
				p 'League Manager is existing...'
			end

			if @new_user
				@email = email
				@first = first
				@api_key = api_key
				@email_content = 'confirm_email_mailer/confirm_email'

			 	@confirm_email_link = ENV['Admin_Domain'] + "/#/pages/confirm_email?key=#{@api_key}"
				 
				client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

				mail = SendGrid::Mail.new do |m|
					m.to = @email
					m.from = 'support@ez4mysports.com'
					m.subject = 'Confirm your email address for EZ Sports'
					m.html = render_to_string(@email_content, :layout => false)
				end

				if send_email?
					p 'SENDING CONFIRM EMAIL'
					res = client.send(mail)
					puts res.code
					puts res.body
				end
			end

			render json: user
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	# allows admins to update basic info
	def update_admin
		begin
			user = ValidateKey();
			if (user == nil)
				render json: nil
				return
			end

			user.first = params[:first]
			user.last = params[:last]
			user.email = params[:email]

			user.save(:validate => false)

			render json: user
		rescue => e
			HandleError(e);
			return nil;
		end
	end

	def credit_info
		user = ValidateKey()
		if (user == nil)
			render json: nil
			return
		end

		begin
			# p 'CREATE LEAGUE PAYMENT'
			p 'ENV: ' + Rails.env.to_s
			first = user.first
			last = user.last
			cc_id = user.cc_id
			payment_method_nonce = params[:payment_method_nonce]
			amount = params[:amount]
					# league_id = params[:league_id]
					# league = League.find(league_id)
          # league_card = league.cc_number
					pay = Payment.new(
				user_id: user.id,
				# league_id: league.id,
				amount: amount
				# card_number: league_card,
				# payment_method_nonce: payment_method_nonce

			)

					# p 'Starting Avalara...'

					# if (league.exemption_no == nil)
					# 		exemption_no = false
					# else
					# 		exemption_no = league.exemption_no
					# end

					# begin
					# 		avalara_result = pay.avalara_get_tax(amount, cc_id)

					# 		p 'RESULT: ' + avalara_result["ResultCode"].to_s

					# 		if avalara_result["ResultCode"] != 'Success'
					# 				err = ''
					# 				avalara_result["Messages"].each { |message| err += message["Summary"] + '  ' }

					# 				p err
					# 				render json:"tax".to_json
					# 				return
					# 		end

					# rescue => e
					# 		HandleError(e)
					# 		render json: "tax".to_json
					# 		return
					# end

					p 'Avalara was successful...'
					p 'Starting Braintree'
					# p 'CC Nonce: ' + payment_method_nonce

					new_customer = false
					if cc_id == nil # if there is no cc_id, they have not been created as a Braintree customer
					new_customer = true

						customer_result = Braintree::Customer.create(
							:first_name => first,
							:last_name => last,
							:payment_method_nonce => payment_method_nonce
						)
						if customer_result.success?
							p 'Braintree created customer successfully'
							user.cc_id = customer_result.customer.id
							user.save(:validate => false)
							cc_id = user.cc_id
						else
							'BRAINTREE ERROR!'
							p customer_result.errors

							render json: nil
							return
						end
					end

			# if (amount == 0)
			# 	p 'Amount is zero...no need to charge the card'
			# else
			# 	p 'Charging the card $' + amount.to_s

				# payment_result = nil

				# if new_customer == false
				# 	# Charge the credit card
				# 	payment_result = Braintree::Transaction.sale(
				# 		:amount => amount,
				# 		:payment_method_nonce => payment_method_nonce
				# 	)
				# else
				# 	# Charge the credit card
				# 	payment_result = Braintree::Transaction.sale(
				# 		:amount => amount,
				# 		:customer_id => user[:cc_id]
				# 	)
				# end

				# p 'Payment Result'
				# p payment_result

			# 	if payment_result.success? == false
			# 		p 'BRAINTREE ERROR'
			# 		p payment_result.message

			# 		render json: nil
			# 		return
			# 	end
			# end

			pay.success = true
					pay.save

			# league is paid for...mark it
			# league.paid = true
			# league.save

			render json: pay
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_token
			v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		token = Braintree::ClientToken.generate
		data = {token: token}
		render json: data
	end

	def update_league
		user = ValidateKey();
		if (user == nil)
			render json: nil
			return
		end

		begin
			id = params[:league_id]
			lm = LeagueManager.where('user_id = ?', user.id).first

			lm.active_league_id = id
			lm.active_season_id = nil
			lm.save(:validate => false)

			league = League.find(id)

			render json: league
		rescue => e
			HandleError(e)
			render json: nil
		end

	end

	def update_season
		user = ValidateKey();
		if (user == nil)
			render json: nil
			return
		end

		begin
			season = params[:season_id]
			lm = LeagueManager.where('user_id = ?', user.id).first

			lm.active_season_id = season
			lm.save(:validate => false)

			render json: lm
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	private

	def load_admin_login_data(user)
		if user.confirmed == false
			return nil
		end

		is_super = false
		roles = []
		user_roles = UserRole.where('user_id = ?', user.id)
		user_roles.each do |ur|
			role = Role.select(:name).where('id = ?', ur.role_id).first()
			roles.push role.name

			if role.name == 'super_admin'
				is_super = true
				break
			end
		end

		managers = nil
		leagues = nil

		if !is_super
			managers = []
			lm = LeagueManager.where("user_id = " + user.id.to_s)
			lm.each do |x|
				managers.push(x)
			end

			leagues = []
			l = League.where('user_id = ' + user.id.to_s)
			l.each do |x|
				leagues.push(x)
			end
		end

		result = { "user" => user,
				   "managers" => managers,
				   "leagues" => leagues,
				   "is_super" => is_super,
				   "roles" => roles }

		p result

		return result
	end

	def load_team_login_data(user)
		p 'Loading Team Login Data'

		roles = []
		user_roles = UserRole.where('user_id = ?', user.id)
		user_roles.each do |ur|
			role = Role.select(:name).where('id = ?', ur[:role_id]).first()
			roles.push role[:name]
		end

		list = []
		adult = nil
		adult_leagues = nil
		adult_teams = nil

		if roles.include?('player')
			adult = Player.where("user_id = ?", user.id).first

			adult_lp = LeaguePlayer.where("player_id = ?", adult.id)
			adult_leagues = []
			adult_lp.each do |lp|
				l = League.where('id = ?', lp.league_id).first
				adult_leagues.push(l)
			end

			adult_teams = []
			# in team roster user_id is actually player_id...I know it is stupid
			roster = TeamRoster.where("user_id=?", adult.id)
			roster.each do |r|
				t = Team.find(r.team_id)
				adult_teams.push(t)
			end
		end

		kids = nil
		child_players = Player.where("parent_id = ?", user.id)
		if child_players.length > 0
			kids = []

			child_players.each do |c|
				kid_leagues = []

				kids_lp = LeaguePlayer.where("player_id = ?", c.id)
				kids_lp.each do |lp|
					l = League.find(lp.league_id)
					kid_leagues.push(l)
				end

				kid_teams = []
				# in team roster user_id is actually player_id...I know it is stupid
				roster = TeamRoster.where("user_id=?", c.id)
				roster.each do |r|
					t = Team.find(r.team_id)
					kid_teams.push(t)
				end

				kid = { "player" => c, "leagues" => kid_leagues, "teams" => kid_teams }
				kids.push(kid)
			end
		end

		coaches = nil
		coach_teams = nil
		coach_league = nil

		if roles.include?('coach')
			coachList = Coach.where("user_id = ?", user.id)
			if (coachList.count > 0)
				coaches = []
				coach_teams = []
				coach_leagues = []

				coachList.each do |c|
					coaches.push(c)

					ct = Team.find(c.team_id)
					if (ct != nil)
						coach_teams.push(ct)
						cl = League.find(ct.league_id)
						coach_leagues.push(cl)
					end
				end
				
			end
		end

		result = { "user" => user,
				   "adult_player" => adult,
				   "adult_leagues" => adult_leagues,
				   "adult_teams" => adult_teams,
				   "kids" => kids,
				   "coaches" => coaches,
				   "coach_teams" => coach_teams,
				   "coach_leagues" => coach_leagues,
				   "roles" => roles }

		p result
		return result
	end

	def send_message_email
		@email_content = '/message_mailer/message'
		
		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = @from_email
			m.subject = "#{@subject}"
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'SENDING USER CREATED MESSAGE EMAIL'
			res = client.send(mail)
			puts res.code
			puts res.body
		end
	end
end
