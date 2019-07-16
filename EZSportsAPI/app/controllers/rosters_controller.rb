class RostersController < BaseController
  before_action :validate

  def index
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    @rosters = Roster.all
    render json: @rosters
  end

  def add_player_to_team
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    team = params[:team_id]
    player = params[:user_id]
    roster = TeamRoster.new(user_id: player, team_id: team)
    roster.save
    render json: roster
  end

  def remove_player_from_team
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    team = params[:team_id]
    player = params[:user_id]
    roster = TeamRoster.where("user_id = ? and team_id = ?", player, team).first.destroy
    render json: roster
  end

  def available_players
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    teams = Team.select(:id).where('league_id = ? and season_id = ?', params[:league_id], params[:season_id])
    taken_players = []
    teams.each do |t|
      tp = TeamRoster.select(:user_id).where(team_id: t[:id])
      tp.each do |r|
        taken_players.push(r[:user_id])
      end
    end

    p 'Taken Players'
    p taken_players

    if taken_players.length > 0
      league_players = LeaguePlayer.where('league_id = ? and player_id NOT IN (?)', params[:league_id], taken_players)
    else
      league_players = LeaguePlayer.where('league_id = ?', params[:league_id])
    end

    players = []
    league_players.each do |l|
      player = Player.where('id = ? and players.season_id IS NOT NULL', l[:player_id]).first
      if player.blank?
        # no result
      else
        players.push(player)
      end
    end
    render json: players
  end

  def show_team
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end
    
    roster = TeamRoster.select(:user_id).where(team_id: params[:id])
    roster_players = []
    roster.each do |rp|
      roster_players.push(rp[:user_id])
    end

    begin
      league_players = LeaguePlayer.select(:player_id).where("player_id in (?) and league_id = ?", roster_players, params[:league_id])
      # league_players = LeaguePlayer.select(:player_id).where("player_id in (?)", roster_players)
    rescue => e
      HandleError(e)
    end
    players = []

    if league_players != nil
      league_players.each do |r|
        begin
          player = Player.find(r[:player_id])
          players.push(player)
        rescue => e
          HandleError(e)
        end
      end
    end

    render json: players
  end
end
