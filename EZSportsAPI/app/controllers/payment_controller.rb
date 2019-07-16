require 'date'

class PaymentController < BaseController
	before_action :validate

	def active_player_count_by_league
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		# Find all active players
		players = Player.select('id').where("players.season_id IS NOT NULL").all
		p players
		#league_players = [] # This is an array of all active players

		# Now find each league_player associated with each player so we can get league_ids
		# players.each do |p|
			lp = LeaguePlayer.where("player_id in (?)", players.map {|i| i.id} )
			#league_players.push(lp)

		#end

		# Get the set of unique league_ids [{league_id: 1, player_id: 2}, {league_id: 2, player_id: 4}]
		leagues = lp.uniq{|x,y| x[:league_id]}
		league_ids = []
		leagues.each do |l,z|
			league_ids.push(l[:league_id])
		end

		# Now cycle through the active league_players to count how many players were active per league and build the object to return
		league_payment_objects = []
		league_ids.uniq.each do |leagueid|
			players_per_league = lp.select {|x,y| x[:league_id] == leagueid }
			count = players_per_league.count
			league_object = League.find(leagueid)
			manager = User.find(league_object[:user_id])
			league_payment_objects.push({league: league_object, user: manager, count: count})
		end

		render json: league_payment_objects
	end

	def all
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		render json: Payment.all
	end

	def history
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		league_id = params[:id]
		history = Payment.where('league_id = ?', league_id.to_i)
		render json: history.all
	end

	def automated_payments
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		p "AUTOMATED PAYMENTS"
		results = []
		
		type = params[:type]
		p 'Type: ' + type
		
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
			if (type == 'first' && days <= 15) || (type == 'second' && days > 15)
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
			end
		end
		
		p 'AUTOMATED PAYMENTS COMPLETE'
		p results
		
		render json:results
	end

	# DEPRECATED...
	def charge_users
				v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

		p "CHARGE USERS"
		results = []
		# Send an array of objects from the frontend named transactions: [{user: userobj1, amount: 10}, {user: userobj7, amount: 17}, etc.]
		transactions = params[:transactions]
		p transactions

		transactions.each do |t|
			league = t[:league]
			league = League.find(league[:id])
			user = t[:user]

			if (league.discount_code == 'DEM00' || league.discount_code == 'BETA00')
				next
			end

			# time to calculate the amount
			# the amount is the number of players on any team in
			# the league * $1
			teams = Team.where('league_id = ?', league[:id])
			count = 0
			teams.each do |x|
				# does this team have anything on the schedule in the last 30 days?
				thirty = Date.today - 30
				schedules = GameSchedule.where("(home_id = ? or away_id = ?) and time >= ?", x.id, x.id, thirty).order('time desc')
				p 'TEST: ' + schedules.length.to_s
				if schedules.length == 0
					next
				end

				count += TeamRoster.where('team_id = ?', x.id).length
			end

			amount = count * 1 # changed to $1 4/11/16
			p 'AMOUNT: ' + amount.to_s

			if amount == nil || amount <= 0
				p "Invalid amount: " + amount.to_s
				result = { 	"user" => user,
							"league" => league,
							"error" => "invalid amount",
							"amount" => nil
						 }
				results.push(result)
				next
			end

			pay = Payment.new(user_id: user[:id], league_id: league[:id], amount: amount)

			p 'Starting Avalara...'
			if (league[:exemption_no] == nil)
				exemption_no = false
			else
				p 'Exempt: ' + league[:exemption_no].to_s
				exemption_no = league[:exemption_no]
			end

			# if the user is not exempt and the amount is 0 then we are done
			if exemption_no == false && amount == 0
				next
			end

			begin
				avalara_result = pay.avalara_get_tax(league, amount, user[:cc_id], exemption_no)

								p 'RESULT: ' + avalara_result["ResultCode"].to_s

				if avalara_result["ResultCode"] != 'Success'
										err = ''
										avalara_result["Messages"].each { |message| err += message["Summary"] + '  ' }

					result = { 	"user" => user,
								"league" => league,
								"error" => err,
								"amount" => nil
							 }
					results.push(result)

					next
				end

			rescue => e
				result = { 	"user" => user,
							"league" => league,
							"error" => e,
							"amount" => nil
						 }
				results.push(result)
				HandleError(e)
				next
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
							"error" => e,
							"amount" => nil
						 }
				results.push(result)
				next
			end

			p 'Braintree is done'
			p payment

			p 'Saving payment to DB'
			pay.success = payment.success?
			pay.save

			result = { 	"user" => user,
						"league" => league,
						"error" => nil,
						"amount" => amount,
						"payment" => pay
					 }

			results.push(result)
		end

		render json: results
	end

	def create_league_payment
		user = ValidateKey()
		if (user == nil)
			render json: nil
			return
		end

		begin
			p 'CREATE LEAGUE PAYMENT'
			p 'ENV: ' + Rails.env.to_s

			first = user.first
			last = user.last
			cc_id = user.cc_id

			result=Braintree::PaymentMethodNonce.create(user.credit_card.token)
			payment_method_nonce = result.payment_method_nonce.nonce

			amount = params[:amount]
			league_id = params[:league_id]
			league = League.find(league_id)

			pay = Payment.new(
				user_id: user.id,
				league_id: league.id,
				amount: amount
			)

			p 'Starting Avalara...'

			if (league.exemption_no == nil)
					exemption_no = false
			else
					exemption_no = league.exemption_no
			end

			begin
					avalara_result = pay.avalara_get_tax(league, amount, cc_id, exemption_no)

					p 'RESULT: ' + avalara_result["ResultCode"].to_s

					if avalara_result["ResultCode"] != 'Success'
							err = ''
							avalara_result["Messages"].each { |message| err += message["Summary"] + '  ' }

							p err
							render json:"tax".to_json
							return
					end

			rescue => e
					HandleError(e)
					render json: "tax".to_json
					return
			end

			p 'Avalara was successful...'
			p 'Starting Braintree'
			p 'CC Nonce: ' + payment_method_nonce

			if (amount == 0)
				p 'Amount is zero...no need to charge the card'
			else
				p 'Charging the card $' + amount.to_s

				payment_result = nil

				# Charge the credit card
				payment_result = Braintree::Transaction.sale(
					:amount => amount,
					:payment_method_nonce => payment_method_nonce
				)

				p 'Payment Result'
				p payment_result

				if payment_result.success? == false
					p 'BRAINTREE ERROR'
					p payment_result.message

					render json: nil
					return
				end
			end

			pay.success = true
			pay.save

			# league is paid for...mark it
			league.paid = true
			league.save

			render json: pay
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_token
			v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		token = Braintree::ClientToken.generate
		data = {token: token}
		render json: data
	end

	def new
		begin
					v = ValidateKey()
				if (v == nil)
					render json: nil
					return
				end
					
			user_id = params[:user_id]
			league = League.find(params[:league_id])
			exemption_no = if league.exemption_no.nil?
			false
			else
			league.exemption_no
			end
			amount = params[:amount]
			success = true
			payment = Payment.create(user_id: user_id, league_id: league.id, success: success)
			payment.calculate_tax(league, amount, user_id, exemption_no)
			render json: payment
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	private
	
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
