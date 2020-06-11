class UsersController < ApplicationController
  before_action :authenticate, only: %i(update destroy twitter_profile)

  # /users
  def create
    user = User.new(user_params)

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    unless user.save
      render json: { "code": 500, "message": 'ユーザーの作成に失敗しました' }, status: :internal_server_error
      return
    end

    params[:tags]&.map do |tag_id|
      user.tags << Tag.find(tag_id)
    end

    render json: user.json
  end

  # /users/:id
  def show
    user = User.find_by(id: params[:id])

    if user.blank?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    render json: user.json
  end

  # /users/:id
  def update
    user = User.find_by(id: params[:id])

    if user.blank?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    # ログインユーザのみに権限を与える
    if @user != user
      render json: { "code": 403, "message": 'ユーザを更新する権限がありません。' }, status: :forbidden
      return
    end

    user.attributes = user_params

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    unless user.save
      render json: { "code": 500, "message": 'ユーザーの更新に失敗しました' }, status: :internal_server_error
      return
    end

    render json: user.json
  end

  # /users/:id
  def destroy
    user = User.find_by(id: params[:id])

    if user.blank?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    # ログインユーザのみに権限を与える
    if @user != user
      render json: { "code": 403, "message": 'ユーザを削除する権限がありません。' }, status: :forbidden
      return
    end

    unless user.destroy
      render json: { "code": 500, "message": 'ユーザーの削除に失敗しました' }, status: :internal_server_error
      return
    end

    render json: { "code": 200, "message": '削除しました' }, status: :ok
  end

  # /users/:id/tags
  def tags
    user = User.find([params[:id]]).first
    res = []
    res = user.tags.map(&:json) if user.tags.present?
    render json: res
  end

  # /users/:id/twitter_profile
  def twitter_profile; end

  private

  def user_params
    params.permit(:name, :bio, :image, :email, :password, :oauth_token, :oauth_token_secret)
  end
end
