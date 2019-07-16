class LeaguesController < BaseController
	before_action :validate

	def all
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			leagues = League.all
			render json: leagues
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def validate_coupon
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			code = params[:coupon].upcase
			if (code == 'DEM00' || code == 'BETA00' || code == 'MLD00' || code == "PSEL00".downcase || code == "PSMI00".downcase || code == "PSHI00".downcase || code == "PRIV00".downcase)
				render json: 99.to_json
			elsif (code == "TRDS1")
				render json: 80.to_json
			elsif (code == "TRDS2")
				render json: 60.to_json
			elsif (code == "TRDS3")
				render json: 40.to_json
			elsif (code == "TRDS4")
				render json: 20.to_json
			else
				render json: false.to_json
			end
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_adult_leagues
		begin
			result = []
			leagues = League.where("age = 'Adult'")
			leagues.each do |league|
				count = LeaguePlayer.where("league_id = " + league.id.to_s).count
				if league.limit == nil || count < league.limit
					result.push(league)
				end
			end
			render json: result
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

			league = params[:id]
			leagueRecord = League.where('id = ?', league).first
			if (league == nil)
				render json: true
				return
			end

			p 'Found League ' + league.to_s + ' : Deleting...'

			seasons = Season.where("league_id = ?", league)
			LogInfo("Deleting " + seasons.length.to_s + " Seasons [" + league.to_s + "]")
			seasons.destroy_all

			teams = Team.where("league_id = ?", league)
			LogInfo("Deleting " + teams.length.to_s + " Teams [" + league.to_s + "]")
			teams.destroy_all

			venues = Venue.where("league_id = '?'", league)
			LogInfo("Deleting " + venues.length.to_s + " Venues [" + league.to_s + "]")
			venues.destroy_all

			league_players = LeaguePlayer.where("league_id = ?", league)
			LogInfo("Deleting " + league_players.length.to_s + " League Players [" + league.to_s + "]")
			league_players.destroy_all

			games_schedules = GameSchedule.where("league_id = ?", league)
			LogInfo("Deleting " + games_schedules.length.to_s + " Games [" + league.to_s + "]")
			games_schedules.destroy_all

			League.destroy(leagueRecord);

			render json: "true".to_json
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def new
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			name = params[:name]
			zip = params[:zip]
			age = params[:age]
			sport = params[:sport]
			image = params[:image]
			user_id = params[:user_id]
			latitude = params[:latitude]
			longitude = params[:longitude]
			exempt = params[:exempt]
			limit = params[:limit]
			discount = params[:discount]
			cc_number = params[:cc_number]
			cvv_number = params[:cvv_number]
			exp_month = params[:exp_month]
			exp_year = params[:exp_year]
			last_digit = params[:last_digit]
			

			league = nil

			if (id != nil)
				league = League.find(id)
				league.name = name
				league.zip = zip
				league.age = age
				league.sport = sport
				league.image = image
				league.longitude = longitude
				league.latitude = latitude
				league.exemption_no = exempt
				league.discount_code = discount
				league.limit = limit
				league.cc_number = cc_number
				league.cvv_number = cvv_number
				league.exp_month = exp_month
				league.exp_year = exp_year
				league.last_digit = last_digit
			else
				league = League.new(name: name, zip: zip, age: age, sport: sport, image: image, user_id: user_id, latitude: latitude, longitude: longitude, exemption_no: exempt, discount_code: discount, limit: limit, cc_number: cc_number, cvv_number: cvv_number, exp_month: exp_month, exp_year: exp_year, last_digit: last_digit)
				
			end
			league.save
			last_digit = league.cc_number.to_s.last(4)
			league_last = league.update(last_digit: last_digit)
			
			# is this a new sport?
			list = Sport.find_by(name: sport)
			if list == nil
				p 'New Sport! ' + sport
				Sport.create(name: sport)
			end
			
			role_id = Role.where("name = ?", "manager").first.id
	    	user_role = UserRole.new(user_id: user_id, role_id: role_id, league_id: league.id)
	    	user_role.save

			p league

			render json: league
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def players
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			players = User.where(league_id: id)
			LogInfo('Players for specfic league')
			render json: players
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def available_players
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		user_roster = TeamRoster.select(:user_id).all

		if (user_roster.length > 0)
			not_available = []
			user_roster.each do |f|
				not_available.push(f.user_id)
			end
		else
			not_available = [0]
		end

		LogInfo("Getting available players for roster")
		available = User.where('id not in (?)', not_available).where(league_id: params[:id])
		render json: available
	end

	def get_by_user
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end
		user_id = params[:user_id]

		LogInfo("Getting leagues for user")

		leagues = League.where("user_id = ?", user_id)
		
		render json: leagues
	end

	# def user
	# 	league_manager_key = params[:user_api_key]
	# 	league = League.where(league_manager_key: league_manager_key)

	# 	render json: league
	# end
# cc_number = params[:number]
		# payments = Payment.where("user_id = ?", user_id)
		# payments = Payment.find(params[:user_id])
		# payment = payments.cc_number
end
