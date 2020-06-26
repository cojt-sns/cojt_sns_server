class Public::GroupUsersController < ApplicationController
  # get /public/groups/:id/group_users
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

    unless group.public
      render json: { "code": 403, "message": '不正なアクセスです' }, status: :forbidden
      return
    end

    render json: group.group_users.map(&:json)
  end

  # get /public/group_users/:id
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

    unless group_user.group.public
      render json: { "code": 403, "message": '不正なアクセスです' }, status: :forbidden
      return
    end

    render json: group_user.json
  end

  private

  def group_user_params
    params.permit(:name, :answers, :introduction)
  end
end
