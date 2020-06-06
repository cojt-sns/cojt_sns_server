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
    render json: [
      {
        "group": {
          "id": 1,
          "twitter_traceability": false,
          "questions": [
            "スマブラのプレイ時間は?"
          ],
          "introduction": false,
          "tags": [
            0
          ]
        }
      }
    ]
  end

  # get /groups/{id}
  def show
    group = Group.find_by(id: params[:id])
    
    if !group.public?
      render json: { "code": 403, "message": "privateグループのため、見れません"}, status: 403
      return 
    end
    if group.nil?
      render json: { "code": 404, "message": "該当するグループが存在しません。"}, status: 404
      return 
    end
    render json:group
    # render json: {
    #   "id": @group.id,
    #   "twitter_traceability": @group.twitter_traceability,
    #   "questions": @group.questions,
    #   "introduction": @group.introduction,
    #   "tags": @group.tags
    # }
  end

  # put /groups/{id}
  def update
    render json: {
      "id": 1,
      "twitter_traceability": false,
      "questions": [
        "スマブラのプレイ時間は?"
      ],
      "introduction": false,
      "tags": [
        0
      ]
    }
  end
end
