class SuperAdminController < BaseController
	def get_sales_agents
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			list = SalesAgent.all
			render json: list
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_payment_report
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			startdate = params[:start]
			enddate = params[:end]

			if (startdate == nil || enddate == nil)
				render json: "Bad Date".to_json
				return
			end

			m, d, y = startdate.split '-'
			if !Date.valid_date? y.to_i, m.to_i, d.to_i
				render json: "Bad Date".to_json
				return
			end

			m, d, y = enddate.split '-'
			if !Date.valid_date? y.to_i, m.to_i, d.to_i
				render json: "Bad Date".to_json
				return
			end


			list = PaymentLog.where('process_date >= ? and process_date < ?', startdate, enddate)
			render json: list
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def get_commission_report
		# v = ValidateKey()
		# if (v == nil)
		# 	render json: nil
		# 	return
		# end
		begin

			p 'Get Commission Report'

			# start_date = params[:start]
			# end_date = params[:end]

			filter = params[:filter]


			list = SalesAgent.all.order("last asc")
			all_leagues = League.all
			all_teams = Team.all
			all_rosters = TeamRoster.all

			result = []

			list.each do |sa|
				p 'Agent: ' + sa.email

				new_leagues = 0
				total_leagues = 0
				total = 0

				if sa.zipcodes == '' || sa.zipcodes == nil
					next
				end

				p sa.zipcodes
				sa.zipcodes.each do |z|
					leagues = all_leagues.where("zip = ?", z)
					leagues.each do |l|
						total_leagues += 1

						if (l.created_at < Date.now-30.days)
							if (filter == 'All' || filter == 'Leagues')
								p 'New League... ' + l.id.to_s
								new_leagues += 1

								val = CalcLeagueCharge(l.discount_code)
								p 'League Charge: ' + val.to_s
								total += val
							end
						else
							if (filter == 'All' || filter == 'Players')
								p 'Old league... ' + l.id.to_s

								# active players
								p 'Calc Active Players...'
								teams = all_teams.where('league_id = ?', l.id)
								count = 0
								
								teams.each do |team|
									count += all_rosters.where('team_id = ?', team.id).length
								end

								p 'Active Count: ' + count.to_s

								total += (count * 2) * 0.2
							end
						end					
					end
				end
				
				obj = { "agent" => sa,
					   	"new_leagues" => new_leagues,
					   	"total_leagues" => total_leagues,
					   	"total_amount" => total }

				p 'Adding Object'
				p obj

				result.push(obj)
			end

			render json: result
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def save_sales_agent
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			p 'Saving Sales Agent'

			id = params[:id]
			first = params[:first]
			last = params[:last]
			email = params[:email]
			zipcodes = params[:zipcodes]


			sa = nil
			if id == '' || id == nil
				# create
				sa = SalesAgent.new()
			else
				# update
				sa = SalesAgent.find(id)
			end

			sa.first = first
			sa.last = last
			sa.email = email

			if zipcodes != nil && zipcodes != ''
				sa.zipcodes = zipcodes
			end

			p sa

			sa.save

			p 'SA Saved'
			render json: sa
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def delete_sales_agent
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			sa = SalesAgent.find(id)
			sa.destroy

			render json: sa
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	private

	def CalcLeagueCharge(code)
		amount = 0

		if (code == 'DEM00' || code == 'BETA00' || code == "PSEL00".downcase || code == "PSMI00".downcase || code == "PSHI00".downcase || code == "PRIV00".downcase)
			# Free codes
			amount = 0
		elsif (code == "TRDS1")
			amount = 80 * 0.2
		elsif (code == "TRDS2")
			amount = 60 * 0.2
		elsif (code == "TRDS3")
			amount = 40 * 0.2
		elsif (code == "TRDS4")
			amount = 20 * 0.2
		else
			amount = 99 * 0.2
		end

		return amount
	end
end
