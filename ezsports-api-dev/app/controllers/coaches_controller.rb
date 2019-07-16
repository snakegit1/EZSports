class CoachesController < BaseController
  before_action :validate

  def attach_coach
	v = ValidateKey()
	if (v == nil)
		render json: nil
		return
	end

	user_id = params[:user_id]
	team_id = params[:team_id]
	coach = Coach.where(user_id: user_id, team_id: team_id).count
	if coach == 0
	  coach = Coach.create(user_id: user_id, team_id: team_id)
	end
	render json: coach
  end

  def get_teams
    v = ValidateKey()
    if (v == nil)
      render json: nil
      return
    end

	user_id = params[:user_id]
	teams_coached = Coach.where("user_id = ?", user_id)
	teams = []
	teams_coached.each do |t|
	  teams.push(t.team_id)
	end
	render json: teams
  end

  def remove_coach_from_team
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

	user_id = params[:user_id]
	team_id = params[:team_id]
	coaches = Coach.where("user_id = ?", user_id)
	coaches.each do |coach|
	  if coach.team_id == team_id
		coach.destroy
	  end
	end

	render json: true
  end

  def select_coach
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

	team_id = params[:team_id]
	coaches = Coach.where("team_id = ?", team_id)
	users = []
	coaches.each do |coach|
	  u = User.find(coach.user_id)
	  users.push(u)
	end
	render json: users
  end

  def league_coaches
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

	league_id = params[:league_id]
	role_id = Role.where("name = ?", "coach").first.id
	user_roles = UserRole.where(role_id: role_id, league_id: league_id) # get user_roles for coaches so we can get those user_ids
	user_ids = []

	user_roles.each do |ur|
	  user_ids.push(ur.user_id) # extract user_ids from coach user_roles from above
	end

	users = User.where(id: user_ids) # this will loop through the user_ids array
	render json: users
  end

  def new
    v = ValidateKey()
  	if (v == nil)
  		render json: nil
  		return
  	end

	@first = params[:first]
	@last = params[:last]
	@email = params[:email]
	randomString = SecureRandom.hex
	@password = randomString[0..5] # assign them a temporary password
	@api_key = SecureRandom.hex
	league_id = params[:league_id]

	role_id = Role.where("name = ?", "coach").first.id
	u = User.find_by(email: @email)
	if u != nil
		coach = UserRole.where(user_id: u.id, role_id: role_id, league_id: league_id).first
		if coach != nil
			# this guy is good to go
			render json: u
			return
		end

		user_role = UserRole.new(user_id: u.id, role_id: role_id, league_id: league_id)
		user_role.save

		@email_content = '/signup_mailer/existing_coach'
	else
		u = User.new(first: @first, last: @last, email: @email, password: @password, temp_password: true, api_key: @api_key )
		u.save(:validate => false)

		user_role = UserRole.new(user_id: u.id, role_id: role_id, league_id: league_id)
		user_role.save

		@email_content = '/signup_mailer/new_user_coach'
	end

	league = League.find(league_id)

	@link = ENV['Team_Domain'] + "/#/"
    
	@league = league.name
	
	client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

	mail = SendGrid::Mail.new do |m|
		m.to = @email
		m.from = 'support@ez4mysports.com'
		m.subject = 'You have been registered as a coach with EZ Sports'
		m.html = render_to_string(@email_content, :layout => false)
	end

	if send_email?
		p 'SENDING COACH EMAIL'
		res = client.send(mail)
		puts res.code
		puts res.body
	end
	
	render json: u
  end

  def remove_coach
	v = ValidateKey()
	if (v == nil)
		render json: nil
		return
	end

	coach = params[:coach]
	league_id = params[:league_id]

	role_id = Role.where("name = ?", "coach").first.id

	user_role = UserRole.select(:id).where(user_id: coach, role_id: role_id, league_id: league_id)
	UserRole.destroy(user_role)

	c = Coach.where("user_id = ?", coach).first
	if c != nil
		Coach.destroy(c)
	end

	render json: "success"
  end

  def update
	begin
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end
		
		email = params[:email]
		first = params[:first]
		last = params[:last]

		coach = User.find(params[:id])
		coach.first = first
		coach.last = last
		coach.email = email
		coach.save(:validate => false)

		render json:coach
	rescue => e
		HandleError(e)
		render json: nil
	end
  end

end
