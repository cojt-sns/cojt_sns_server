class Public::GroupUsersController < ApplicationController
  # get /public/groups/:id/group_users
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
  
  # get /public/group_users/:id
  def show
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

  private

  def group_user_params
    params.permit(:name, :answers, :introduction)
  end
end
