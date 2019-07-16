class SportsController < BaseController
	def get
		begin
			list = Sport.all.order("name asc")
			render json: list
		rescue => e
			HandleError(e)
			render json: nil
		end
	end
	
	def test
		begin
			list = Sport.find_by(name: "Flag Football")
			render json: list
		rescue => e
			HandleError(e)
			render json: nil
		end
	end
end