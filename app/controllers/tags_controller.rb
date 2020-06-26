class TagsController < ApplicationController
  before_action :authenticate, only: [:create]

  # GET /tags
  # タグ検索
  def index
    # パラメータチェック
    if params[:descendants].present? && (params[:descendants] =~ /[^0-9]+/ || params[:descendants].to_i.negative?)
      render json: { "code": 400, "message": 'descendantsの指定が不適切です。' }, status: :bad_request
      return
    end

    descendants = params[:descendants].present? ? params[:descendants].to_i : 0

    json = search(params[:name], descendants)

    render json: json
  end

  # GET /tags/{id}
  # タグ取得
  def show
    # パラメータチェック
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: 'Bad Request' }, status: :bad_request
      return
    end

    tag = Tag.find_by(id: params[:id])
    # 存在チェック
    if tag.nil?
      render json: { code: '404', message: '存在しないTagです' }, status: :not_found
      return
    end

    # 正常系
    render json: tag.json
  end

  # POST /tag
  # タグ作成
  def create
    # 親タグ取得
    parent = nil
    if params[:parent_id].present?
      parent = Tag.find_by(id: params[:parent_id])

      if parent.nil?
        render json: { code: '400', message: '親タグの指定が不適切です' }, status: :bad_request
        return
      end
    end

    # タグ登録
    tag = Tag.new
    tag.name = params[:name]
    tag.parent_id = parent&.id

    # バリデーションチェック
    unless tag.valid?
      render json: { "code": 400, "message": tag.errors.messages }, status: :bad_request
      return
    end

    # DB保存
    unless tag.save
      render json: { "code": 500, "message": 'タグを生成できませんでした。' }, status: :internal_server_error
      return
    end

    parent&.users&.map do |user|
      ActionCable.server.broadcast("notification_#{user.id}", title: 'タグが追加されました', description: tag.fullname)
    end

    # 正常系
    render json: tag.json
  end

  private

  def search(name, descendants)
    tags = Tag.where('name like ?', "%#{name}%")

    res = []
    tags.each do |tag|
      res << {
        "tag": tag.json,
        "ancestors": tag.ancestors.map(&:json),
        "descendants": tag.descendants.select { |t| t.tree_level - tag.tree_level <= descendants }.map(&:json)
      }
    end
    res
  end
end
