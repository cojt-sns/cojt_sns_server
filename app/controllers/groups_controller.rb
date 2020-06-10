class GroupsController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  # get /groups
  def index
    if params[:tag_ids].nil?
      groups = Group.where(public: true)
      render json: groups.map{|g| g.json}
      return 
    end

    tag = Tag.find_by(id: params[:tag_ids])

    if tag.nil?
      render json:{ "code": 402, "message": "該当するタグが存在しません。"}, status: 402
      return 
    end
    groupSearchResult=tag.groups

    render json:groupSearchResult
  end

  # post /groups
  def create
    #必須項目が入力されたか確認 
    if params[:questions].nil? || !params[:questions].is_a?(Array)
      render json: { "code": 400, "message": "質問事項を入力してください。"}, status: 400
      return 
    end

    if params[:tags].nil?
      render json: { "code": 400, "message": "タグを入力してください。"}, status: 400
      return 
    end

    params[:questions].each do |question|
      if question.include?("$")
        render json: { "code": 400, "message": "質問事項に「$」を含めないでください。"}, status: 400
        return 
      end
    end

    group = Group.new
    
    params[:tags].each do |tag_id|
      tag = Tag.find_by(id: tag_id)
      if tag.nil?
        render json: { "code": 400, "message": "タグが存在しません" }, status: 400
        return
      end
      group.tags << tag
    end

    group.questions = params[:questions].join('$')
      
    group.twitter_traceability = params[:twitter_traceability] if params[:twitter_traceability]
    group.introduction = params[:introduction] if params[:introduction]
    group.public = params[:public]if params[:public]

    if !group.valid?
      render json: { "code": 400, "message": group.errors.messages }, status: 400
      return
    end
    
    #groupを作れなかった時のエラー
    if !group.save
      render json: { "code": 500, "message": "グループを生成できませんでした。" }, status: 500
      return
    end

    render json: group.json
  end

  # get /groups/{id}
  def show
    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end

    if !group.public
      render json: { "code": 403, "message": "privateグループのため、見れません"}, status: 403
      return 
    end
    
    render json: group.json
  end

  # put /groups/{id}
  def update
    if !params[:questions].is_a?(Array)
      render json: { "code": 400, "message": "質問事項は配列で入力してください。"}, status: 400
      return 
    end

    params[:questions]&.each do |question|
      if question.include?("$")
        render json: { "code": 400, "message": "質問事項に「$」を含めないでください。"}, status: 400
        return 
      end
    end

    group = Group.find_by(id: params[:id])

    #グループが存在しない場合のエラー
    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end

    # TODO:グループメンバーか否か

    if params[:tags]
      group.tag = [] 
      params[:tags].each do |tag_id|
        tag = Tag.find_by(id: tag_id)
        if tag.nil?
          render json: { "code": 400, "message": "タグが存在しません" }, status: 400
          return
        end
        group.tags << tag
      end
    end

    group.questions = params[:questions].join('$') if params[:questions]
    group.twitter_traceability = params[:twitter_traceability] if params[:twitter_traceability]
    group.introduction = params[:introduction] if params[:introduction]
    group.public = params[:public] if params[:public]

    if !group.valid?
      render json: { "code": 400, "message": group.errors.messages }, status: 400
      return
    end

    if !group.save
      render json: { "code": 500, "message": "グループを編集できませんでした。" }, status: 500
      return
    end

    render json: group.json
  end
end
