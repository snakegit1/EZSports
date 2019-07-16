require 'csv'

class GameSchedulesController < BaseController
  before_action :set_game_schedule, only: [:show, :edit, :update, :destroy]
  before_action :validate

  def index
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    league_id = params[:league_id].to_i
    # p league_id
    begin
      collect = []
      p 'Getting Schedules'

      list = GameSchedule.where('league_id = ?', league_id).order('time desc')
      list.each do |f|
          collect.push(f.info)
      end

      # p collect
      render :json => collect
    rescue => e
      HandleError(e)
      render json: nil
    end
  end

  def coach
    begin
        v = ValidateKey()
        if (v == nil)
        	render json: nil
        	return
        end
      user_id = params[:user_id]
      league_id = params[:league_id]
      list = []

      coach = Coach.where("user_id = ? ", user_id)
      coach.each do |c|
          team = Team.find(c.team_id)
          if league_id != nil && team.league_id != league_id
              next
          end

          teams.push(team)

          schedule = GameSchedule.where("(home_id = ? or away_id = ?) and time >= ?", c.team_id, c.team_id, DateTime.now).order('time asc')

          obj = { "team" => team, "schedule" => schedule }
          list.push(obj)
      end

      render :json => list
    rescue => e
      HandleError(e)
    end
  end

  def player
    begin
        v = ValidateKey()
    	if (v == nil)
    		render json: nil
    		return
    	end

      player_id = params[:player_id]
      league_id = params[:league_id]
      list = []
      # in teamroster, user_id is actually the player id
      rosters = TeamRoster.where("user_id = ? ", player_id)
      rosters.each do |r|
          team = Team.find(r.team_id)

          if league_id != nil && team.league_id != league_id
              next
          end

          teams.push(team)

          schedule = GameSchedule.where("(home_id = ? or away_id = ?) and time >= ?", r.team_id, r.team_id, DateTime.now).order('time asc')

          obj = { "team" => team, "schedule" => schedule }
          list.push(obj)
      end

      render :json => list
    rescue => e
      HandleError(e)
    end
  end

  def team_schedules
    begin
      v = ValidateKey()
    	if (v == nil)
    		render json: nil
    		return
    	end

      team_id = params[:team_id]
      collect = []
      schedules = GameSchedule.where("home_id = ? or away_id = ?", team_id, team_id).order('time desc')
      schedules.each do |s|
        collect.push(s.info)
      end
      render :json => collect
    rescue => e
      HandleError(e)
    end
  end

  def show
    begin
      game = @game_schedule.info
      render :json => game
    rescue => e
      HandleError(e)
      render json: nil
    end
  end

  def new
    #@game_schedule = GameSchedule.new
    #return json: @game_schedule
  end

  def edit
  end

  def create
    begin
      p 'CREATE GAME SCHEDULE'

        v = ValidateKey()
    	if (v == nil)
    		render json: nil
    		return
    	end

      @game_schedule = GameSchedule.new(game_schedule_params)

      p @game_schedule

      if @game_schedule.schedule_type == nil || @game_schedule.schedule_type == ''
        @game_schedule.schedule_type = 'Game'
      end

      p 'AFTER: ' +  @game_schedule.schedule_type

      @game_schedule.save
      if @game_schedule.persisted?
        render :json => @game_schedule
      else
        render :json => nil
      end
    rescue => e
      HandleError(e)
      render json: nil
    end
  end

  def update
    begin
      p 'UPDATING SCHEDULE'
      v = ValidateKey()
    	if (v == nil)
    		render json: nil
    		return
    	end

      @game_schedule = GameSchedule.new(game_schedule_params)
      @game_schedule.id = params[:id]

      if @game_schedule.schedule_type == nil || @game_schedule.schedule_type == ''
        @game_schedule.schedule_type = 'Game'
      end

      @game_schedule.update(game_schedule_params)
      @game_schedule.save
      render :json => @game_schedule
    rescue => e
      render :json => nil
    end
  end

  def destroy
    begin
        v = ValidateKey()
    	if (v == nil)
    		render json: nil
    		return
    	end
        
      @game_schedule.destroy
      render json: 'destroyed'
    rescue => e
      HandleError(e)
      render json: nil
    end
  end

  def upload
    begin
      v = ValidateKey()
      if (v == nil)
        render json: nil
        return
      end

      error = nil
      count, @errors_array = GameSchedule.upload(params[:file], params[:league_id])

      if @errors_array.size > 0

        league = League.where(id: params[:league_id]).first
        @user  = league.user
        @email = @user.email
        @email_content = '/game_mailer/error_details'

        client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

        mail   = SendGrid::Mail.new do |m|
          m.to      = @email
          m.from    = 'support@ez4mysports.com'
          m.subject = 'Regarding errors in csv upload'
          m.html    = render_to_string(@email_content, :layout => false)
        end

        if send_email?
          p 'SENDING ERROR IN GAME UPLOAD EMAIL'
          res = client.send(mail)
          puts res.code
          puts res.body
        end

        error = "We found errors and we have emailed them to you with detail"
      end

      render json: {count: count, error: error}
    rescue => e
      HandleError(e)
      render json: nil
    end
  end

  def download_sample_csv
    v = ValidateKey()
    if (v == nil)
      render json: nil
      return
    end

    send_file(
      GameSchedule.sample_csv_path,
      filename: "sample_schedules.csv",
      type: "text/csv"
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_schedule
      @game_schedule = GameSchedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_schedule_params
      params.require(:game_schedule).permit(:home_id, :away_id, :venue_id, :time, :league_id, :schedule_type)
    end
end
