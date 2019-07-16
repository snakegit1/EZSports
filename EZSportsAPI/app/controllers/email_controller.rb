require 'sendgrid-ruby'
require 'date'
require 'time_difference'
# docs for timedifference gem https://github.com/tmlee/time_difference

class EmailController < BaseController

  def set_game_reminders
    begin
        LogInfo('Checking Game Reminders')
        date_now = DateTime.now

        LogInfo('Getting future games : ' + date_now.to_s)
        list = GameSchedule.where('time >= ?', date_now)

        LogInfo('Found ' + list.length.to_s + ' game(s)')

        list.each do |game|
            difference = TimeDifference.between(date_now, game.time).in_days.ceil

            if difference == 7
                get_users(game)
            elsif difference == 1
                get_users(game)
            end
        end

        LogInfo('Set Game Reminders Complete')
        head :ok
    rescue => e
        HandleError(e)
        head 500
    end
  end


private

def get_users(game)
    LogInfo('get_users')
    LogInfo(game)
    # a user_roster matches one user_id with one team_id
    player_rosters = []

    h = TeamRoster.where('team_id = ?', game.home_id)
    a = TeamRoster.where('team_id = ?', game.away_id)
    player_rosters = h.push(*a) # combine the two arrays
    p player_rosters

    home = nil
    if (game.home_id != 0)
        home = Team.find(game.home_id)
    end
    
    away = nil
    if (game.away_id != 0)
        away = Team.find(game.away_id)
    end

    venue = Venue.find(game.venue_id)

    # LogInfo('Game : ' + home.name + ' vs ' + away.name + ' @ ' + venue.name + ' on ' + game.time.strftime("%B %e, %Y at %I:%M %p"))

    if (home != nil)
        @home_team = home.name
    else
        @home_team = 'N/A'
    end

    if (away != nil)
        @away_team = away.name
    else
        @away_team = 'N/A'
    end

    @venue_name = venue.name
    @date = game.time.strftime("%B %e, %Y at %I:%M %p") # converts time to readable string, see ruby docs

    players = []

    player_rosters.each do |roster|
        player = Player.find_by_id(roster.user_id) # bad data design...roster.user_id is actually the player...

        if player != nil
            p player
            players.push(player)
        end
    end

    p 'Going through roster...'
    players.each do |player|
        if send_email?
            user = nil

            if (player.parent_id != nil)
                user = User.find_by_id(player.parent_id)
            else
                user = User.find_by_id(player.user_id)
            end

            if user == nil
                LogInfo('Could not find user...')
                next
            end

            @first = player.first
            @email = user.email
            send_email

            if (player.other_contacts != nil)
                p 'Parsing other contacts...'
                split = player.other_contacts.split(/,/)
                split.each do |e|
                    if is_a_valid_email?(e)
                        LogInfo('Other contact is valid...emailing: ' + e)
                        @email = e
                        send_email
                    end
                end
            end
        end
    end

  end

    def send_email
        @email_content = '/reminder_mailer/reminder'
		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'info@ez4mysports.com'
			m.subject = 'EZ Sports - Game reminder'
			m.html = render_to_string(@email_content, :layout => false)
		end

        if send_email?
            
			LogInfo('SENDING GAME REMINDER EMAIL: To [' + @email + ']')
			res = client.send(mail)
			puts res.code
			puts res.body
        end
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

    def is_a_valid_email?(email)
      (email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    end
end
