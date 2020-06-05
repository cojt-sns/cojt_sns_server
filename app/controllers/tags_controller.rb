class TagsController < ApplicationController
  before_action :authenticate, only: [:create]
  
  # GET /tags
  def index
    render json: 
      [
        {
          "tag": {
            "id": 1,
            "name": "情報メディア創成学類",
            "parent_id": 0,
            "fullname": "筑波大学.情報学群.情報メディア創成学類"
          },
          "ancestors": [
            {
              "id": 1,
              "name": "情報メディア創成学類",
              "parent_id": 0,
              "fullname": "筑波大学.情報学群.情報メディア創成学類"
            }
          ],
          "children": [
            {
              "id": 1,
              "name": "情報メディア創成学類",
              "parent_id": 0,
              "fullname": "筑波大学.情報学群.情報メディア創成学類"
            }
          ]
        }
      ]
  end

  # GET /tags/{id}
  def show
    # パラメータチェック
    if params[:id].nil? && params[:id] =~ /[^0-9]+$/
      render json: {code: "400", message: "Bad Request"}, status: 400
      return
    end

    tag = Tag.find_by(id: params[:id])
    # 存在チェック
    if tag.nil?
      render json: {code: "404", message: "存在しないTagです"}, status: 404
      return
    end

    # 正常系
    json = {
      "id": tag.id,
      "name": tag.name,
      "parent_id": tag.parent_id,
      "fullname": tag.fullname
    }
    render json: json
  end

  # POST /tag
  def create
    render json: {
      "id": 1,
      "name": "情報メディア創成学類",
      "parent_id": 0,
      "fullname": "筑波大学.情報学群.情報メディア創成学類"
    }
  end
end
