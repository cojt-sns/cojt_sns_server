class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def health_check
    users = User.count
    render json: { "message": 'success', "users": users }
  end

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      auth = AuthenticateToken.find_by(token: token)

      @token = token
      @user = auth&.user

      !auth.nil? && auth.check
    end
  end
end
