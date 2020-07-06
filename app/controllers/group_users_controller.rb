class GroupUsersController < ApplicationController
  before_action :authenticate, only: [:update]

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

  private

  def group_user_params
    params.permit(:name, :image)
  end
end
