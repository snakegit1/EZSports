class TeamsController < BaseController
	before_action :validate

	def get_player_teams
      begin
		  v = ValidateKey()
	  	if (v == nil)
	  		render json: nil
	  		return
	  	end

        player_id = params[:player_id]
        teams = []

		# in teamroster, user_id is actually the player id
        rosters = TeamRoster.where("user_id = ? ", player_id)
		rosters.each do |r|
			team = Team.find(r.team_id)
			teams.push(team)
		end

		teams.sort! { |a,b| a.name.downcase <=> b.name.downcase }
        render :json => teams
      rescue => e
        HandleError(e)
      end
    end

	def create_team
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			name = params[:name]
			season_id = params[:season_id]
			image_path = params[:image]
			league_id = params[:league_id]

			if id == nil
				team = Team.new(name: name, season_id: season_id, image_path: image_path, league_id: league_id)
			else
				team = Team.find(id)
				team = team.update_attributes(name: name, season_id: season_id, image_path: image_path, league_id: league_id)
			end

			team.save

			render json: team
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_team_members
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			team_id = params[:team_id]
			team = Team.find(team_id)

			if team == nil
				render json: false
				return
			end

			players = []
			league = League.find(team.league_id)
			league_players = LeaguePlayer.where("league_id = ?", team.league_id)
			team_roster = TeamRoster.where("team_id = ?", team_id)

			if (league.age == 'Adult')
				league_players.each do |lp|
					team_roster.each do |tr|
						# it is called user_id...but it is actually the player_id...need to fix that
						if (tr.user_id == lp.player_id)
							players.push(Player.find(lp.player_id))
							break
						end
					end
				end
			elsif
				# for child leagues, we need their parent's email
				league_players.each do |lp|
					team_roster.each do |tr|
						if (tr.user_id == lp.player_id)
				  			player = Player.find(lp.player_id)
							parent = User.where('id = ?', player.parent_id).first
							player.email = parent.email
							players.push(player)
							break
						end
					end
				end
			end

			# Get the manager and add him to the list
			lm = User.where('id = ?', league.user_id).first
			lm.last += ' (LM)'
			players.push(lm)

			p players

			render json: players
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

			team_rosters = TeamRoster.where("team_id = ?", id)
			team_rosters.destroy_all

			home_games = GameSchedule.where("home_id = ?", id)
			away_games = GameSchedule.where("away_id = ?", id)
			home_games.each do |hg|
				hg[:home_id] = nil
				hg.save
			end
			away_games.each do |ag|
				ag[:away_id] = nil
				ag.save
			end

			coaches = Coach.where("team_id = ?", id)
			coaches.destroy_all

			LogInfo('Deleting team ' + id.to_s)
			Team.destroy(id)

			render json: "true".to_s
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def update_season
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			season = params[:season_id]

			LogInfo("Updating team's season " + id.to_s + " | " + season.to_s)
			t = Team.find(id)
			t.season_id = season
			t.save

			render json: t
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_by_season
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		teams = Team.where(season_id: params[:season_id])
		render json: teams
	end

	def get_by_league
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			LogInfo("Getting all teams for league " + id.to_s)

			teams = Team.where("league_id = ?", id).order("name asc")

			render json: teams
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_by_league_active_season
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end
			
			id = params[:id]
			s_id = params[:s_id]
			LogInfo("Getting all teams for league " + id.to_s)

			teams = Team.where("league_id = ? and season_id = ?", id, s_id).order("name asc")

			render json: teams
		rescue => e
			HandleError(e)
			render json: nil
		end
	end
end
