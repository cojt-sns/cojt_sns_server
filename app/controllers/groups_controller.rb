class GroupsController < ApplicationController
  before_action :authenticate, only: [:create, :update]

  # get /groups
  def index
    if params[:tag_ids].nil?
      groupSearchResult=Group.find_by(public: true)
      render json:groupSearchResult
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
    if params[:questions].nil?
      render json: { "code": 400, "message": "質問事項を入力してください。"}, status: 400
      return 
    end
    if params[:tags].nil?
      render json: { "code": 400, "message": "タグを入力してください。"}, status: 400
      return 
    end

    questions=params[:questions]
    question_text=""
    questions.each do |question|
      if question.include?("$")
        render json: { "code": 400, "message": "質問事項に「$」を含めないでください。"}, status: 400
        return 
      end
      question_text = question_text+"$"+question
    end
    question_text=question_text[1,question_text.length]

    tags=[]
    params[:tags].each do |tag1|
      tags.push(Tag.find(tag1))
    end

    group=Group.new(public:true,twitter_traceability: false,questions:question_text,introduction:false,tags:tags)

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

    if !group.valid?
      render json: { "code": 400, "message":group.errors.messages }, status: 400
      return
    end
    
    #groupを作れなかった時のエラー
    if !group.save
      render json: { "code": 500, "message": "グループを生成できませんでした。" }, status: 500
      return
    end

    render json:{"id":group.id,"public":group.public,"twitter_traceability": group.twitter_traceability,"questions":group.questions,"introduction":group.introduction,"tags":group.tags.pluck("id")}
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
    
    render json:{"id":group.id,"public":group.public,"twitter_traceability": group.twitter_traceability,"questions":group.questions,"introduction":group.introduction,"tags":group.tags.pluck("id")}
  
  end

  # put /groups/{id}
  def update

    group = Group.find_by(id: params[:id])

    #グループが存在しない場合のエラー
    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end

    #グループメンバーか否か?

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

    render json:{"id":group.id,"public":group.public,"twitter_traceability": group.twitter_traceability,"questions":group.questions,"introduction":group.introduction,"tags":group.tags.pluck("id")}
  end
end
