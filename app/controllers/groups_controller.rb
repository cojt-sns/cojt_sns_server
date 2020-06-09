class GroupsController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  # get /groups
  def index
    if params[:Tagid].nil?
      groupSearchResult=Group.find_by(public: true)
      render json:groupSearchResult
      return 
    end

    tag = Tag.find_by(id: params[:Tagid])

    if tag.nil?
      render json:{ "code": 402, "message": "該当するタグが存在しません。"}, status: 402
      return 
    end
    groupSearchResult=tag.groups
    render json:groupSearchResult
  end

  # post /groups
  def create
    #tokenが送信されたか確認
    if params[:auth_token].nil?
      render json: { "code": 400, "message": "ログイン情報がないため、ログアウトできません"}, status: 400
      return
    end

    auth = AuthenticateToken.find_by(token: params[:auth_token])

    # トークンの存在を確認
    if auth.nil?
      render json: { "message": "トークンが存在しません" }, status: 401
      return
    end

    if Group.find_by(id: params[:id])
      render json: { "code": 402, "message": "すでに存在するidのため作成できません"}, status: 402
      return 
    end

    #必須項目が入力されたか確認 
    if params[:id].nil?
      render json: { "code": 400, "message": "idを入力してください。"}, status: 400
      return 
    end
    if params[:questions].nil?
      render json: { "code": 400, "message": "質問事項を入力してください。"}, status: 400
      return 
    end
    if params[:tags].nil?
      render json: { "code": 400, "message": "タグを入力してください。"}, status: 400
      return 
    end

    group=Group.new(id: params[:id],public:true,twitter_traceability: false,questions:params[:questions],introduction:false)
    
    #必須でない項目の入力があれば、代入  
    if params[:twitter_traceability]
      group.twitter_traceability=params[:twitter_traceability]
    end
    if params[:introduction]
      group.introduction=params[:introduction]
    end
    if params[:public]
      group.public=params[:public]
    end

    #groupを作れなかった時のエラー
    if !group.save
      render json: { "code": 500, "message": "グループを生成できませんでした。" }, status: 500
      return
    end

    render json: { "code": 200, "message": "グループを作成しました。" }
  end

  # get /groups/{id}
  def show
    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end
    if !group.public?
      render json: { "code": 403, "message": "privateグループのため、見れません"}, status: 403
      return 
    end
    
    render json:group
  end

  # put /groups/{id}
  def update
    #認証トークンがない場合のエラー
    if params[:auth_token].nil?
      render json: { "code": 400, "message": "ログイン情報がないため、ログアウトできません"}, status: 400
      return
    end

    auth = AuthenticateToken.find_by(token: params[:auth_token])
    
    # トークンの存在を確認
    if auth.nil?
      render json: { "message": "トークンが存在しません" }, status: 401
      return
    end

    group = Group.find_by(id: params[:id])

    #グループが存在しない場合のエラー
    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end

    #グループメンバーか否かの判定?
    # if !group.public?
    #   render json: { "code": 403, "message": "グループメンバーでないため、グループの質問事項の編集はできません"}, status: 403
    #   return 
    # end


    #group.update_attribute(id: params[:id],twitter_traceability: params[:twitter_traceability],questions:params[:questions],introduction:params[:introduction],tags:params[:tags])

    if params[:tags]
      group.tags=params[:tags]
    end
    if params[:questions]
      group.questions=params[:questions]
    end
    if params[:twitter_traceability]
      group.twitter_traceability=params[:twitter_traceability]
    end
    if params[:introduction]
      group.introduction=params[:introduction]
    end
    if params[:public]
      group.public=params[:public]
    end

    if !group.save
      render json: { "code": 500, "message": "グループを編集できませんでした。" }, status: 500
      return
    end

    render json: { "code": 200, "message": "グループ情報を更新しました。" }
  end
end
