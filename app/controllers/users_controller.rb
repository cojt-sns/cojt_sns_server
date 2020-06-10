class UsersController < ApplicationController
  before_action :authenticate, only: %i(update delete twitterr_profile)

  # /users
  def create
    user = User.new(user_params)

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end
    
    unless user.save
      render json: { "code": 500, "message": "ユーザーの作成に失敗しました"}, status: 500
      return
    end

    params[:tags].map do |tag_id|
      user.tags << Tag.find(tag_id)
    end

    render json: user.json
  end

  # /users/:id
  def show
    user = User.find(params[:id])
    
    if user.blank?
      render json: { "code": 404, "message": "ユーザが見つかりません。"}, status: 404
      return
    end

    render json: user.json
  end

  # /users/:id
  def update
    user = User.find(params[:id])
    
    if user.blank?
      render json: { "code": 404, "message": "ユーザが見つかりません。"}, status: 404
      return
    end

    user.attributes = user_params

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    unless user.save
      render json: { "code": 500, "message": "ユーザーの更新に失敗しました"}, status: 500
      return
    end

    render json: user.json
  end

  # /users/:id
  def destroy
    user = User.find(params[:id])    
    if user.blank?
      render json: { "code": 404, "message": "ユーザが見つかりません。"}, status: 404
      return
    end

    unless user.destroy
      render json: { "code": 500, "message": "ユーザーの削除に失敗しました"}, status: 500
      return
    end

    render json: { "code": 200, "message": "削除しました"}, status: 200
  end

  # /users/:id/tags
  def tags
    user = User.find([params[:id]]).first
    res = []
    res = user.tags.map{|tag|
      tag.json } if user.tags.present?
    render json: res
  end

  # /users/:id/twitter_profile
  def twitter_profile; end

  private

  def user_params
    params.permit(:name, :bio, :image, :email, :password, :oauth_token, :oauth_token_secret)
  end
end
