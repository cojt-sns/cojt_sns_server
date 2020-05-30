class ApplicationController < ActionController::API
    def health_check
        render json: {"message": "success"}
    end
end
