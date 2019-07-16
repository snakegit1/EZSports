namespace :credit_card do

	desc "Create league payment plans"
	task :charge_users => :environment do
	  # Payment.call(user_id: user.id, league_id: league.id, amount: 500)
	  # puts 'gfdfg';
	  automated_payments
	end

	def automated_payments
		# v = ValidateKey()
		# if (v == nil)
		# 	puts 'gfdfg';
		# 	# render json: nil
		# 	return
		# end

		p "AUTOMATED PAYMENTS"
		results = []
		
		# type = params[:type]
		# p 'Type: ' + type
		
		month = (DateTime.now - 30.days)
		
		# leagues less than 30 days old are not charged
		leagues = League.where('created_at < ?', month)
		leagues.each do |league|
			if (league.discount_code == 'DEM00' || league.discount_code == 'BETA00')
				next
			end
			
			created = league.created_at
			days = created.strftime("%d").to_i
			p 'League ' + league.id.to_s + ' Start Day: ' + days.to_s
			
			# 'first' means we are getting all leagues created before the 16th
			# 'second' gets all leagues created from the 16th - end of the month
			# if (type == 'first' && days <= 15) || (type == 'second' && days > 15)
				result = process_league(league)

				# save successful payments to the log...
				if (result["error"] == nil)
					log = PaymentLog.new()
					log.league_id = result["league"].id
					log.process_date = Time.now
					log.amount = result["amount"]
					log.save
				end

				results.push(result)
			# end
		end
		
		p 'AUTOMATED PAYMENTS COMPLETE'
		p results
		
		# render json:results
	end

 #    def ValidateKey
	# 	begin
	# 		apiKey = request.headers['APIKey']
	# 		p 'APIKey = ' + apiKey.to_s

	# 		if (apiKey == '' || apiKey == nil)
	# 			return nil
	# 		end

	# 		u = User.find_by api_key: apiKey
	# 		if (u == nil)
	# 			return nil
	# 		end

	# 		return u
	# 	rescue => e
	# 		return nil
	# 	end
	# end

	def process_league(league)
			p 'Processing League: ' + league.id.to_s
			
			user = User.find(league.user_id)
			if (user == nil)
				p 'Invalid user'
				result = { 	"user" => nil,
							"league" => league,
							"error" => "invalid user"
						 }
						 
				return result
			end
			
			teams = Team.where('league_id = ?', league.id)
			if (teams.length == 0)
				p 'No teams'
				result = { 	"user" => user,
							"league" => league,
							"error" => "no teams"
						 }
						 
				return result
			end
			
			count = 0
			teams.each do |x|
				# does this team have anything on the schedule in the last 30 days?
				thirty = Date.today - 30
				schedules = GameSchedule.where("(home_id = ? or away_id = ?) and time >= ?", x.id, x.id, thirty).order('time desc')
				p 'Team ' + x.id.to_s + ' events in last 30 days: ' + schedules.length.to_s
				if schedules.length == 0
					next
				end

				count += TeamRoster.where('team_id = ?', x.id).length
			end

			amount = count * 1 # changed to $1 4/11/16
			p 'Charging $: ' + amount.to_s

			if amount == nil || amount < 0
				p "Invalid amount: " + amount.to_s
				result = { 	"user" => user,
							"league" => league,
							"error" => "invalid amount"
						 }
				
				return result;
			end

			pay = Payment.new(user_id: user[:id], league_id: league[:id], amount: amount)

			p 'Starting Avalara...'
			if (league[:exemption_no] == nil)
				exemption_no = false
			else
				p 'League Exempt from Taxes: ' + league[:exemption_no].to_s
				exemption_no = league[:exemption_no]
			end

			# if the user is not exempt and the amount is 0 then we are done
			if exemption_no == false && amount == 0
				p 'Nothing to charge...'
				result = { 	"user" => user,
							"league" => league,
							"error" => 'Nothing to charge'
						 }
							
				return result
			end

			begin
				avalara_result = pay.avalara_get_tax(league, amount, user[:cc_id], exemption_no)

				p 'Avalara Result: ' + avalara_result["ResultCode"].to_s

				if avalara_result["ResultCode"] != 'Success'
					err = ''
					avalara_result["Messages"].each { |message| err += message["Summary"] + '  ' }

					result = { 	"user" => user,
								"league" => league,
								"error" => err
							 }
							 
					return result
				end

			rescue => e
				result = { 	"user" => user,
							"league" => league,
							"error" => e
						 }
				
				return result
			end

			p 'Avalara was successful...charging CC'

			begin
				payment = Braintree::Transaction.sale(
					:amount => amount,
					:customer_id => user[:cc_id]
				)
			rescue => e
				result = { 	"user" => user,
							"league" => league,
							"error" => e
						 }
						 
				return result
			end

			p 'Braintree is done'
			p payment

			p 'Saving payment to DB'
			pay.success = payment.success?
			pay.save

			p 'Payment successful!'
			result = { 	"user" => user,
						"league" => league,
						"error" => nil,
						"amount" => amount,
						"payment" => pay
					 }

			return result
		end
end

