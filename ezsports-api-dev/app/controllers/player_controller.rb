class PlayerController < BaseController
	respond_to :json
	before_action :validate

	def active
	  begin
		player_id = params[:player_id]
		season_id = params[:season_id]

		player = Player.find(player_id)
		player[:season_id] = season_id
		player.save

		render json: player
	  rescue => e
		HandleError(e)
		render json: nil
	  end
	end

	def delete
	  begin
		player_id = params[:player_id]
		league_id = params[:league_id]

		league_players = LeaguePlayer.where("player_id = ? and league_id = ?", player_id, league_id)
		league_players.destroy_all

		player = Player.where(id: player_id).first
		player.delete

		render json: true
	  rescue => e
		HandleError(e)
		render json: nil
	  end
	end

	def get_messages
	  begin
		#get user's player id
		user_id = params[:user_id]
		league_id = params[:league_id]
		player = Player.where("user_id = ?", user_id).first
		if player == nil
		  player = Player.where("parent_id = ?", user_id).first
		end

		messages = Message.where("user_to = ?", player[:id])

		render json: messages

	  rescue => e
		HandleError(e)
		render json: nil
	  end
	end

	def paid
	  begin
		id = params[:id]
		player = Player.find(id)

		if player.paid == true
			player.paid = false
		else
			player.paid = true
		end

		player.save
		render json: player

	  rescue => e
		HandleError(e)
		render json: nil
	  end
	end

	def update
	  begin
		id = params[:id]
		email = params[:email]
		league_age = params[:league_age]
		player = Player.find(id)

		if player == nil
			render json: nil
			return
		end

		if league_age.downcase == 'adult'
			player.first = params[:user_first]
			player.last = params[:user_last]

			# email validation
			if (player.email != email)
				# they changed it...did they steal someone else's?
				check = User.where("email = ?", email).first
				if (check != nil)
					# in use...
					render json: Player.new()
					return
				end
			end

			player.email = email
			player.phone = params[:phone]

			#  the player and user are one and the same...
			u = User.find(player.user_id)
			u.email = email
			u.first = player.first
			u.last = player.last
			u.save(:validate => false)
		else
			player.first = params[:child_first]
			player.last = params[:child_last]

			# get the parent
			p 'Updating parent info...'
			u = User.find(player.parent_id)

			if (u.email != email)
				# they changed it...did they steal someone else's?
				check = User.where("email = ?", email).first
				if (check != nil)
					# in use...
					render json: Player.new()
					return
				end
			end

			u.first = params[:user_first]
			u.last = params[:user_last]
			u.email = email
			u.save(:validate => false)
		end

		player.phone = params[:phone]
		player.gender = params[:gender]
		player.birthday = params[:birthday]

		player.paid = params[:paid]

		player.other_contacts = params[:other_contacts]
		player.ec_first1 = params[:ec_first1]
		player.ec_last1 = params[:ec_last1]
		player.ec_email1 = params[:ec_email1]
		player.ec_phone1 = params[:ec_phone1]

		player.ec_first2 = params[:ec_first2]
		player.ec_last2 = params[:ec_last2]
		player.ec_email2 = params[:ec_email2]
		player.ec_phone2 = params[:ec_phone2]

		player.save

		render json: player
	  rescue => e
		HandleError(e)
		render json:nil
	  end
	end

	def update_account
	  begin
		user_id = params[:user_id]
		email = params[:email]

		list = Player.where('user_id = ? or parent_id = ?', user_id, user_id)

		# if list == nil || list.length == 0
		# 	render json: nil
		# 	return
		# end

		list.each do |player|
			if (player.user_id == user_id)
				# update the adult record
				player.first = params[:first]
				player.last = params[:last]
				player.gender = params[:gender]
				player.birthday = params[:birthday]
			end

			player.phone = params[:phone]
			player.email = email
			player.other_contacts = params[:other_contacts]
			player.ec_first1 = params[:ec_first1]
			player.ec_last1 = params[:ec_last1]
			player.ec_email1 = params[:ec_email1]
			player.ec_phone1 = params[:ec_phone1]

			player.ec_first2 = params[:ec_first2]
			player.ec_last2 = params[:ec_last2]
			player.ec_email2 = params[:ec_email2]
			player.ec_phone2 = params[:ec_phone2]

			player.save
		end

		u = User.find(user_id)
		u.email = email
		u.first = params[:first]
		u.last = params[:last]
		u.save(:validate => false)

		render json: list
	  rescue => e
		HandleError(e)
		render json:nil
	  end
	end

	def update_child
	  begin
		player_id = params[:id]
		gender = params[:gender]
		first = params[:first]
		last = params[:last]
		bday = params[:birthday]

		player = Player.find(player_id)

		if player == nil
			render json: nil
			return
		end

		player.first = params[:first]
		player.last = params[:last]
		player.gender = params[:gender]
		player.birthday = params[:birthday]

		player.save

		render json: player
	  rescue => e
		HandleError(e)
		render json:nil
	  end
	end


	# def update_team_account
	# 	user_id = params[:user_id]
	# 	email = params[:email]
	# 	phone = params[:params]
	# 	first = params[:params]
	# 	last = params[:params]
	#
	# 	other_contacts = params[:other_contacts]
	# 	ec_first1 = params[:ec_first1]
	# 	ec_last1 = params[:ec_last1]
	# 	ec_email1 = params[:ec_email1]
	# 	ec_phone1 = params[:ec_phone1]
	#
	# 	ec_first2 = params[:ec_first2]
	# 	ec_last2 = params[:ec_last2]
	# 	ec_email2 = params[:ec_email2]
	# 	ec_phone2 = params[:ec_phone2]
	#
	#
	# end

	def save
	  begin
		first = params[:user_first]
		last = params[:user_last]
		email = params[:email]
		parent_id = params[:parent_id]
		gender = params[:gender]
		birthday = params[:birthday]
		paid = params[:paid]
		league_id = params[:league_id]
		league_age = params[:league_age]
		user_id = params[:user_id]
		id = params[:id]

		if id == nil
		  player = Player.new(first: first, last: last, email: email, gender: gender, birthday: birthday, paid: paid)

		  if league_age == 'Adult'
			  player.user_id = user_id
		  else
			  player.parent_id = user_id
		  end
		  player.save
		   # now save the user in the LeaguePlayer table
		  lp = LeaguePlayer.new(league_id: league_id, player_id: player.id)
		  lp.save

		  manager = Role.where("name = ?", "manager").first
		  user_roles = UserRole.where("user_id = ? and role_id = ?", user_id, manager[:id])
		  if user_roles == [] || user_roles == nil
			UserRole.create!(user_id: user_id, role_id: manager[:id], league_id: league_id)
		  end

		else

		  player = Player.find(id)
		  player.first = first
		  player.last = last
		  player.email = email
		  player.parent_id = parent_id
		  player.gender = gender
		  player.paid = paid
		  player.user_id = user_id
		  player.save
		end

		render json: player

	  rescue => e
		HandleError(e)
		render json: nil
	  end
	end

	def all_players
	  players = Player.joins(:league_player).where('league_players.league_id = ?', params[:league_id]).order(created_at: :desc).limit(10).offset(params[:off].to_i)
	  parents = []

	  players.each do |p|
		  if (p.parent_id != nil)
			  u = User.find(p.parent_id)
			  parents.push(u)
		  end
	  end

	  p players
	  render json: { players: players, parents: parents }
	end

	def num_players
	  players = LeaguePlayer.where('league_id = ?', params[:league_id]).count
	  render json: players
	end

	def email_search
		decode = URI.unescape(params[:search])
		user = User.search(decode).first
		# @players = Player.joins(:league_player).where('league_players.league_id = ?', params[:league_id]).search(decode)

		p = nil
		if (user != nil)
			p = Player.where('user_id = ?', user.id).first
			if (p == nil)
				p = Player.where('parent_id = ?', user.id).first
				if (p != nil)
					# parent isn't a player, so we have
					# the child here...need to get it loaded right
					p.first = user.first
					p.last = user.last
					p.email = user.email
					p.id = nil
				end
			end
		end

		p p

		render json: p
	end

	def search
		decode = URI.unescape(params[:search])
		players = Player.joins(:league_player).where('league_players.league_id = ?', params[:league_id]).search(decode)
		parents = []

		players.each do |p|
  			if (p.parent_id != nil)
  				u = User.find(p.parent_id)
  				parents.push(u)
  			end
		end

		render json: { players: players, parents: parents }
	end
end
