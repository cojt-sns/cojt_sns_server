class UsersController < ApplicationController
  include ImageControllerModule

  before_action :authenticate, only: %i(update destroy twitter_profile groups)

  # /users
  def create
    user = User.new(user_params)
    set_image(user, params['image'].to_io, "#{user.id}_#{Time.zone.now}") if params['image'].present?

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    unless user.save
      render json: { "code": 500, "message": 'ユーザーの作成に失敗しました' }, status: :internal_server_error
      return
    end

    render json: user.json
  end

  # /users/:id
  def show
    user = User.find_by(id: params[:id])

    if user.nil?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    render json: user.json
  end

  # /users/:id
  def update
    user = User.find_by(id: params[:id])
    set_image(user, params['image'].to_io, "#{user.id}_#{Time.zone.now}") if params['image'].present?

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

  # /users/:id/groups
  def groups
    user = User.find_by(id: params[:id])

    if @user == user
      groups = @user.groups
    else
      if user.nil?
        render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
        return
      end

      if user.private
        render json: { "code": 403, "message": 'アクセス権限がありません' }, status: :forbidden
        return
      end
      groups = user.groups
    end

    render json: groups.map(&:json).to_json
  end

  # /users/:id/twitter_profile
  def twitter_profile; end

  private

  def user_params
    params.permit(:name, :bio, :email, :password, :oauth_token, :oauth_token_secret, :private)
  end
end
