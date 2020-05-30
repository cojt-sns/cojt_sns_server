class ApplicationController < ActionController::API
    def health_check
        tags = Tag.count
        render json: {"message": "success", "tags": tags}
    end
end
