class UsersController < ApplicationController
  before_action :authenticate, only: %i(update delete twitterr_profile)

  # /users
  def create
    user = User.new
    user = set_user_params(user)
    
    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    unless user.save!
      render json: { "code": 500, "message": "ユーザーの作成に失敗しました。"}, status: 500
      return
    end

    render json: user.json
  end

  # /users/:id
  def show; end

  # /users/:id
  def update; end

  # /users/:id
  def destroy; end

  # /users/:id/tags
  def tags; end

  # /users/:id/twitter_profile
  def twitter_profile; end

  private

  def set_user_params(user)
    user.name = user_params['name']
    user.bio = user_params['bio']
    user.image = user_params['image']
    user.email = user_params['email']
    user.password_digest = user_params['password']
    user.oauth_token = user_params['oauth_token']
    user.oauth_token_secret = user_params['oauth_token_secret']
    return user
  end

  def user_params
    params.permit(:id, :name, :bio, :image, :email, :password, :oauth_token, :oauth_token_secret)
  end
end
