class TagsController < ApplicationController
  before_action :authenticate, only: [:create]
  
  # GET /tags
  # タグ検索
  def index
    #パラメータチェック
    if params[:descendants].present? && (params[:descendants] =~ /[^0-9]+/ || params[:descendants].to_i < 0)
      render json: { "code": 400, "message": "descendantsの指定が不適切です。"}, status: 400
      return
    end

    descendants = params[:descendants].present? ? params[:descendants].to_i : 0
    
    tags = Tag.where('name like ?', "%#{params[:name]}%")

    res = []
    tags.each do |tag|
      res << {
        "tag": tag.json,
        "ancestors": tag.ancestors.map{|t| t.json},
        "descendants": tag.descendants.select{|t| t.tree_level - tag.tree_level <= descendants}.map{|t| t.json}
      }
    end

    render json: res
  end

  # GET /tags/{id}
  # タグ取得
  def show
    # パラメータチェック
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
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
    render json: tag.json
  end

  # POST /tag
  # タグ作成
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
    render json: tag.json
  end
end
