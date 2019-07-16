class UserRostersController < BaseController
  before_action :set_user_roster, only: [:edit, :update, :destroy]
  before_action :validate


  # GET /user_rosters
  # GET /user_rosters.json
  def index
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    @user_rosters = UserRoster.all
    render json: @user_rosters
  end

  # GET /user_rosters/1
  # GET /user_rosters/1.json
  def show
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    render json: @users_roster
  end

  # POST /user_rosters
  # POST /user_rosters.json
  def create
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    # roster = Roster.select(:id).where(team_id: params[:team_id]).first()
    user_roster = UserRoster.new(user_id: params[:user_id], team_active_seasons_id: params[:team_id])
    # user_roster = UserRoster.new(user_id: params[:user_id], roster_id: roster.id)

    if user_roster.save
      render json: "true"
    else
      render json: user_roster.errors
    end
  end

  def add_coach
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    # roster = Roster.select(:id).where(team_id: params[:team_id]).first()
    user_roster = CoachRoster.new(user_id: params[:user_id], team_active_seasons_id: params[:team_id])
    # user_roster = UserRoster.new(user_id: params[:user_id], roster_id: roster.id)

    if user_roster.save
      render json: "true"
    else
      render json: user_roster.errors
    end
  end

  # PATCH/PUT /user_rosters/1
  # PATCH/PUT /user_rosters/1.json
  def update
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    if @user_roster.update(user_roster_params)
      render json: "true"
    else
      render json: @user_roster.errors
    end
  end

  def remove_users
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    identify = UserRoster.destroy_all(:user_id => params[:ids])
    render json: 'true'
  end

  def remove_user
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

    # @user_roster.destroy
    query = UserRoster.where("user_id = ? and team_active_seasons_id = ?", params[:user_id], params[:team_id]).destroy_all
    render json: query
  end

  def remove_user
      v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end
    
    # @user_roster.destroy
    query = CoachRoster.where("user_id = ? and team_active_seasons_id = ?", params[:user_id], params[:team_id]).destroy_all
    render json: query
  end

  # DELETE /user_rosters/1
  # DELETE /user_rosters/1.json
  def destroy
    # @user_roster.destroy
    # UserRoster.where(:user_id => params[:id]).where(:team_active_seasons_id => params[:team_id]).destory
    # render json: "true"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_roster
      @user_roster = UserRoster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_roster_params
      params.require(:user_roster).permit(:user_id, :roster_id)
    end
end
