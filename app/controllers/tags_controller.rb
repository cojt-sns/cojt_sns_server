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
    if params[:id].nil? || params[:id] =~ /[^0-9]+$/
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
    # パラメータチェック
    if params[:name].nil? || params[:name] =~ /[\.\#@\/\\]+/
      render json: {code: "400", message: "タグ名が不適切です"}, status: 400
      return
    end

    if params[:parent_id].present? && params[:parent_id] =~ /[^0-9]+/
      render json: {code: "400", message: "親タグの指定が不適切です"}, status: 400
      return
    end

    # 親タグ取得
    parent = nil
    if params[:parent_id].present?
      parent = Tag.find_by(id: params[:parent_id])

      if parent.nil?
        render json: {code: "400", message: "親タグの指定が不適切です"}, status: 400
        return
      end
    end

    #タグ登録
    tag = Tag.new
    tag.name = params[:name]
    tag.parent_id = parent&.id

    #バリデーションチェック
    if !tag.valid?
      render json: { "code": 400, "message": tag.errors.messages }, status: 400
      return
    end
    
    # DB保存
    if !tag.save
      render json: { "code": 500, "message": "タグを生成できませんでした。" }, status: 500
      return
    end

    # 正常系
    render json: {
      "id": tag.id,
      "name": tag.name,
      "parent_id": tag.parent_id,
      "fullname": tag.fullname
    }
  end
end
