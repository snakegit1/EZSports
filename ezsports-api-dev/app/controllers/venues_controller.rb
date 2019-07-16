class VenuesController < BaseController
	before_action :validate
	respond_to :json

	def active
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			venue = Venue.find(id)

			if venue.active == true
				venue.active = false
			else
				venue.active = true
			end
			venue.save
			render json: venue
		rescue => e
			HandleError(e)
			render json: nil
		end
	end

	def add
		begin
			v = ValidateKey()
			if (v == nil)
				render json: nil
				return
			end

			id = params[:id]
			name = params[:name]
			first = params[:first]
			last = params[:last]
			address_1 = params[:address_1]
			address_2 = params[:address_2]
			city = params[:city]
			state = params[:state]
			zip = params[:zip]
			phone = params[:phone]
			email = params[:email]
			league_id = params[:league_id]
			active = params[:active]
			is_available = params[:is_available]
			longitude = params[:longitude]
			latitude = params[:latitude]

			if !id
				venue = Venue.new(name: name, first: first, last: last, address_1: address_1, address_2: address_2, city: city,
					state: state, zip: zip, phone: phone, email: email, league_id: league_id, active: active, is_available: is_available, longitude: longitude, latitude: latitude)
				venue.save
			else
				venue = Venue.find(id)
				venue = venue.update(name: name, first: first, last: last, address_1: address_1, address_2: address_2, city: city,
					state: state, zip: zip, phone: phone, email: email, league_id: league_id, active: active, is_available: is_available, longitude: longitude, latitude: latitude)
			end

			render json: venue
		rescue => e
			HandleError(e)
			render json: nil
		end

	end

	def all
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end

		league_id = params[:league_id]
		venues = Venue.where("league_id = ?", params[:league_id])
		render json: venues
	end

	def delete
		v = ValidateKey()
		if (v == nil)
			render json: nil
			return
		end
		
		id = params[:id]
		venue = Venue.find(id)
		games_schedules = GameSchedule.where("venue_id = ?", venue.id)
		games_schedules.each do |gs|
			gs[:venue_id] = nil
			gs.save
		end
		Venue.delete(venue)
		render json: true
	end

end
