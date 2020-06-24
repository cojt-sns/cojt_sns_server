class GroupUsersController < ApplicationController
  before_action :authenticate

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

    unless group_user.group.users.where(id: @user&.id).exists?
      render json: { "code": 403, "message": '不正なアクセスです' }, status: :forbidden
      return
    end

    render json: group_user.json
  end

  # put /group_users/:id
  def update
    render json: {
      "id": 1,
      "name": "ushu",
      "introduction": "スマブラ世界ランカー",
      "answers": [
        "100h"
      ],
      "icon_url": "/neko.png"
    }
  end
  
  # get /groups/:id/group_users
  def group
    render json: [
      {
        "id": 1,
        "name": "ushu",
        "introduction": "スマブラ世界ランカー",
        "answers": [
          "100h"
        ],
        "icon_url": "/neko.png"
      }
    ]
  end
  
  private

  def group_user_params
    params.permit(:name, :answers, :introduction)
  end
end
