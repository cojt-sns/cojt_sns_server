class UsersController < ApplicationController
  before_action :authenticate, only: %i(update destroy twitter_profile groups)

  # /users
  def create
    if params[:tags].present? && !params[:tags].is_a?(Array)
      render json: { "code": 400, "message": 'タグの指定が不適切です' }, status: :bad_request
      return
    end

    user = User.new(user_params)

    unless user.valid?
      render json: { "code": 400, "message": user.errors.messages }, status: :bad_request
      return
    end

    params[:tags]&.map do |tag_id|
      tag = Tag.find_by(id: tag_id)
      if tag.nil?
        render json: { "code": 400, "message": '存在しないタグを指定しています' }, status: :bad_request
        return
      end
      user.tags << tag
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

    if user.blank?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    render json: user.json
  end

  # rubocop:disable Metrics/AbcSize

  # /users/:id
  def update
    if params[:tags].present? && !params[:tags].is_a?(Array)
      render json: { "code": 400, "message": 'タグの指定が不適切です' }, status: :bad_request
      return
    end

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

    user.tags = [] if params[:tags]
    params[:tags]&.map do |tag_id|
      tag = Tag.find_by(id: tag_id)
      if tag.nil?
        render json: { "code": 400, "message": '存在しないタグを指定しています' }, status: :bad_request
        return
      end
      user.tags << tag
    end

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

  # rubocop:enable Metrics/AbcSize

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
    user = User.find_by(id: params[:id])

    if user.blank?
      render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
      return
    end

    res = []
    res = user.tags.map(&:json) if user.tags.present?
    render json: res
  end

  # /users/:id/groups
  def groups
    user = User.find_by(id: params[:id])

    if @user == user
      groups = @user.groups
    else
      if user.blank?
        render json: { "code": 404, "message": 'ユーザが見つかりません。' }, status: :not_found
        return
      end
      groups = user.groups.where(public: true)
    end

    render json: groups.map(&:json).to_json
  end

  # /users/:id/twitter_profile
  def twitter_profile; end

  private

  def user_params
    params.permit(:name, :bio, :image, :email, :password, :oauth_token, :oauth_token_secret)
  end
end
