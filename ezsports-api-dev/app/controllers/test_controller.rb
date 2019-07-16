class TestController < BaseController
	def is_system_up
      begin
		render json:true
      rescue => e
        render json:false
      end
    end

    def is_database_up
      begin
      	list = User.all

		render json:true
      rescue => e
      	p e
        render json:false
      end
    end
end