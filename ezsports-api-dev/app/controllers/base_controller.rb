require 'sendgrid-ruby'

class BaseController < ApplicationController
	
	CORALOGIX_PRIVATE_KEY = "11340519-db9e-ee68-b713-be19f684196e"
	CORALOGIX_APP_NAME = "EZ"
	CORALOGIX_SUB_SYSTEM = "API"
	Coralogix::CoralogixLogger.configure(CORALOGIX_PRIVATE_KEY, CORALOGIX_APP_NAME, CORALOGIX_SUB_SYSTEM)

# protect_from_forgery with: :null_session
	def ValidateKey
		begin
			apiKey = request.headers['APIKey']
			p 'APIKey = ' + apiKey.to_s

			if (apiKey == '' || apiKey == nil)
				return nil
			end

			u = User.find_by api_key: apiKey
			if (u == nil)
				return nil
			end

			return u
		rescue => e
			return nil
		end
	end

	def send_email?
		return true
		# if Rails.env == "development"
		# 	return false
		# else
		# 	return true
		# end
	end

	def validate
		# Yes...validation is being done twice technically...need to clean this up
    	return true
    	
		user = ValidateKey();
		if (user == nil)
			render json: nil
			return
		end
	end

	def LogInfo(txt, category = nil)
		if (category == nil)
			category = "API"
		end 
		
		logger = Coralogix::CoralogixLogger.get_logger(category)
		user = ValidateKey();
		msg = Time.now.to_s

		if (user != nil)
			msg = msg + ' [' + user[:api_key].to_s + ']'
		end

		msg = msg + ' : ' + txt

		logger.verbose(msg)
		p msg
	end

	def HandleError(ex)
		p ex.message
		p ex.backtrace

		logger = Coralogix::CoralogixLogger.get_logger('ERROR')
		logger.error(ex.message + ' \n\n ' + ex.backtrace.join('\n'))
	end

	def send_user_signup_email
	    @email_content = '/signup_mailer/user_signup_email'
	    @link = ENV['Team_Domain']
		
		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'support@ez4mysports.com'
			m.subject = "Welcome to EZ Sports!"
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'SENDING COMPLETE SIGNUP TEAM EMAIL'
			res = client.send(mail)
			puts res.code
			puts res.body
        end
	end

	def send_admin_new_child_email
		@email_content = '/signup_mailer/send_admin_new_child_email'
		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'support@ez4mysports.com'
			m.subject = @first + " is ready for EZ Sports!"
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'Sent new child email'
			res = client.send(mail)
			puts res.code
			puts res.body
        end
	    
	end

	def send_admin_new_parent_user_email
		@email_content = '/signup_mailer/admin_new_parent_user_email'
		@link = ENV['Team_Domain'] + "/#/pages/confirm-email?key=" + @userkey
		
		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'support@ez4mysports.com'
			m.subject = 'Welcome to EZ Sports'
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'Sent new parent user email'
			res = client.send(mail)
			puts res.code
			puts res.body
        end
	end

	def send_admin_new_user_email
	    @email_content = '/signup_mailer/admin_new_user_email'
    	@link = ENV['Team_Domain'] + "/#/pages/confirm-email?key="+@userkey

		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'support@ez4mysports.com'
			m.subject = 'Welcome to EZ Sports'
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'SENDING COMPLETE SIGNUP ADMIN EMAIL'
			res = client.send(mail)
			puts res.code
			puts res.body
        end
	    
	end

	def send_admin_new_player_email
		@email_content = '/signup_mailer/admin_new_player_email'

		client = SendGrid::Client.new(api_key: ENV['SENDGRID'])

		mail = SendGrid::Mail.new do |m|
			m.to = @email
			m.from = 'support@ez4mysports.com'
			m.subject = 'You have joined an EZ Sports League!'
			m.html = render_to_string(@email_content, :layout => false)
		end

		if send_email?
			p 'SENDING COMPLETE SIGNUP ADMIN EMAIL'
			res = client.send(mail)
			puts res.code
			puts res.body
        end
	end

end
