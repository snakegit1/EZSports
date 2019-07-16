class SeasonsController < BaseController
	before_action :validate

	def save_season
		begin
			user = ValidateKey()
			if (user == nil)
				render json: nil
				return
			end

			id = params[:id]
			name = params[:name]
			is_active = params[:is_active]
			league = params[:league_id]
			team_size = params[:team_size]

			if (id == nil)
				p 'Creating new season...' + name
				s = Season.new(name: name, is_active: is_active, league_id: league, team_size: team_size)
				s.save
			else
				p 'Updating season ' + name
				s = Season.find(id)
				s.name = name
				s.is_active = is_active
				s.league_id = league
				s.team_size = team_size
				s.save

				lm = LeagueManager.where('user_id = ?', user.id).first

				if (lm.active_season_id == id)
					lm.active_season_id = nil
					lm.save
				end
			end

			render json: s
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	# Not sure this is used...
	def update_active
		begin
			user = ValidateKey()
			if (user == nil)
				render json: nil
				return
			end

			id = params[:id]
			is_active = params[:is_active]

			LogInfo("Updating active season " + id + " | " + is_active)
			s = Season.find(id)
			s.is_active = is_active
			s.save

			lm = LeagueManager.where('user_id = ?', user.id).first

			if (lm.active_season_id == id)
				lm.active_season_id = nil
				lm.save
			end

			render json: s
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def delete
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		id = params[:id]
		teams = Team.where("season_id = ?", id)
		gs = []
		teams.each do |t|
			GameSchedule.where("home_id = ? or away_id = ?", t[:id], t[:id]).each do |game|
				game.destroy
				puts "Deleted GS!"
			end
		end
		players = Player.where("season_id = ? or active_season_id = ?", id, id)
		players.each do |p|
			p[:season_id] = nil
			p[:active_season_id] = nil
			p.save
		end

		teams = Team.where("season_id = ?", id)
		teams.each do |t|
			t[:season_id] = nil
			t.save
		end

		lms = LeagueManager.where("active_season_id = ?", id)
		lms.each do |x|
			x[:active_season_id] = nil
			x.save
		end

		Season.destroy(id)
		render json: "true".to_s
	end

	def get_by_league
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end
			
			league = params[:league_id]

			LogInfo("Getting all seasons for league " + league.to_s)
			list = Season.where("league_id = " + league).order("name asc")

			render json: list
		rescue => e
			HandleError(e)
			render json: nil
		end
	end
end
