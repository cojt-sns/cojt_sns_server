class GroupUsersController < ApplicationController
  include ImageControllerModule

  before_action :authenticate, only: %i(update group_login_user authorization unauthorization)

  # get /group_users/:id
  def show
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end

    group_user = GroupUser.find_by(id: params[:id])

    if group_user.nil?
      render json: { code: 404, message: '存在しないグループユーザです' }, status: :not_found
      return
    end

    render json: group_user.json
  end

  # rubocop:disable Metrics/AbcSize

  # put /group_users/:id
  def update
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end
    group_user = GroupUser.find_by(id: params[:id])
    if group_user.nil?
      render json: { code: 404, message: '存在しないグループユーザです' }, status: :not_found
      return
    end

    if group_user.user != @user
      render json: { "code": 403, "message": '不正なアクセスです。ログインユーザーでないと、プロフィールを編集できません。' }, status: :forbidden
      return
    end

    group_user.attributes = group_user_params
    if params['image'].present?
      set_image(group_user, params['image'].to_io, "#{@user.id}-#{group_user.id}_#{Time.zone.now}")
    end

    unless group_user.valid?
      render json: { "code": 400, "message": group_user.errors.messages }, status: :bad_request
      return
    end

    unless group_user.save
      render json: { "code": 500, "message": 'ユーザーの更新に失敗しました' }, status: :internal_server_error
      return
    end

    render json: group_user.json
  end

  # rubocop:enable Metrics/AbcSize

  # get /groups/:id/group_users
  def group
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end

    group = Group.find_by(id: params[:id])
    if group.nil?
      render json: { code: 404, message: '存在しないグループです' }, status: :not_found
      return
    end

    render json: group.group_users.map(&:json)
  end

  # get /groups/:id/group_user
  def group_login_user
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end

    group = Group.find_by(id: params[:id])
    if group.nil?
      render json: { code: 404, message: '存在しないグループです' }, status: :not_found
      return
    end

    group_user = group.group_users.find_by(user: @user)
    if group_user.nil?
      render json: { "code": 403, "message": '不正なアクセスです。ログインユーザーでないと、プロフィールを編集できません。' }, status: :forbidden
      return
    end

    render json: group_user.json
  end

  # post /group_users/:id/authorization
  def authorization
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end
    group_user = GroupUser.find_by(id: params[:id])
    if group_user.nil?
      render json: { code: 404, message: '存在しないグループユーザです' }, status: :not_found
      return
    end

    if group_user.group.group_users.find_by(user: @user, admin: true).nil?
      render json: { "code": 403, "message": 'グループへの管理者権限が存在するユーザのみ権限を追加することができます' }, status: :forbidden
      return
    end

    if group_user.admin
      render json: { "code": 400, "message": '既に管理者権限が存在します' }, status: :forbidden
      return
    end

    group_user.admin = true

    unless group_user.valid?
      render json: { "code": 400, "message": group_user.errors.messages }, status: :bad_request
      return
    end

    unless group_user.save
      render json: { "code": 500, "message": 'ユーザーの更新に失敗しました' }, status: :internal_server_error
      return
    end

    render json: group_user.json
  end

  # rubocop:disable Metrics/AbcSize
  # post /group_users/:id/unauthorization
  def unauthorization
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: 400, message: 'Bad Request' }, status: :bad_request
      return
    end
    group_user = GroupUser.find_by(id: params[:id])
    if group_user.nil?
      render json: { code: 404, message: '存在しないグループユーザです' }, status: :not_found
      return
    end

    if group_user.group.group_users.find_by(user: @user, admin: true).nil?
      render json: { "code": 403, "message": 'グループへの管理者権限が存在するユーザのみ権限を変更することができます' }, status: :forbidden
      return
    end

    if group_user.group.group_users.where(admin: true).count < 2
      render json: { "code": 403, "message": 'グループの管理者は1人以上必要です' }, status: :forbidden
      return
    end

    unless group_user.admin
      render json: { "code": 400, "message": '既に管理者権限が存在しません' }, status: :forbidden
      return
    end

    group_user.admin = false

    unless group_user.valid?
      render json: { "code": 400, "message": group_user.errors.messages }, status: :bad_request
      return
    end

    unless group_user.save
      render json: { "code": 500, "message": 'ユーザーの更新に失敗しました' }, status: :internal_server_error
      return
    end

    render json: group_user.json
  end

  # rubocop:enable Metrics/AbcSize

  private

  def group_user_params
    params.permit(:name)
  end
end
