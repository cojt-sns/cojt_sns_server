class GroupsController < ApplicationController
  before_action :authenticate, only: %i(create update)

  # rubocop:disable Metrics/AbcSize

  # get /groups
  def index
    or_ = false

    # タグ指定なし
    if params[:tag_ids].nil?
      groups = Group.where(public: true)
      render json: groups.map(&:json)
      return
    end

    if params[:tag_ids] =~ /[^0-9 ]/
      render json: { "code": 400, "message": 'タグの指定が不適切です' }, status: :bad_request
      return
    end

    or_ = params[:or] if params[:or] == 'true'

    groups = Group
    if !or_
      groups = Group.joins(:group_tags)
      tag_ids = params[:tag_ids].split(' ').map(&:to_i)
      groups = groups
               .where(public: true)
               .merge(GroupTag.where(tag_id: tag_ids))
               .group(:group_id)
               .having('count(groups.id) = ?', tag_ids.length)
    else
      groups = Group.none
      params[:tag_ids].split(' ').map(&:to_i).each do |tag_id|
        groups = groups.or(Group.joins(:tags).where(tags: { id: tag_id }, public: true))
      end
    end

    render json: groups.uniq(&:id).map(&:json)
  end

  # post /groups
  def create
    # 必須項目が入力されたか確認
    if params[:questions].nil? || !params[:questions].is_a?(Array)
      render json: { "code": 400, "message": '質問事項を入力してください。' }, status: :bad_request
      return
    end

    if params[:tags].nil?
      render json: { "code": 400, "message": 'タグを入力してください。' }, status: :bad_request
      return
    end

    params[:questions].each do |question|
      if question.include?('$')
        render json: { "code": 400, "message": '質問事項に「$」を含めないでください。' }, status: :bad_request
        return
      end
    end

    group = Group.new

    params[:tags].each do |tag_id|
      tag = Tag.find_by(id: tag_id)
      if tag.nil?
        render json: { "code": 400, "message": 'タグが存在しません' }, status: :bad_request
        return
      end
      group.tags << tag
    end

    group.questions = params[:questions].join('$')

    group.twitter_traceability = params[:twitter_traceability] if params[:twitter_traceability]
    group.introduction = params[:introduction] if params[:introduction]
    group.public = params[:public] if params[:public]

    unless group.valid?
      render json: { "code": 400, "message": group.errors.messages }, status: :bad_request
      return
    end

    # groupを作れなかった時のエラー
    unless group.save
      render json: { "code": 500, "message": 'グループを生成できませんでした。' }, status: :internal_server_error
      return
    end

    render json: group.json
  end

  # rubocop:enable Metrics/AbcSize

  # get /groups/{id}
  def show
    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    unless group.public
      render json: { "code": 403, "message": 'privateグループのため、見れません' }, status: :forbidden
      return
    end

    render json: group.json
  end

  # rubocop:disable Metrics/AbcSize

  # put /groups/{id}
  def update
    unless params[:questions].is_a?(Array)
      render json: { "code": 400, "message": '質問事項は配列で入力してください。' }, status: :bad_request
      return
    end

    params[:questions]&.each do |question|
      if question.include?('$')
        render json: { "code": 400, "message": '質問事項に「$」を含めないでください。' }, status: :bad_request
        return
      end
    end

    group = Group.find_by(id: params[:id])

    # グループが存在しない場合のエラー
    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    # TODO: グループメンバーか否か

    if params[:tags]
      group.tags = []
      params[:tags].each do |tag_id|
        tag = Tag.find_by(id: tag_id)
        if tag.nil?
          render json: { "code": 400, "message": 'タグが存在しません' }, status: :bad_request
          return
        end
        group.tags << tag
      end
    end

    group.questions = params[:questions].join('$') if params[:questions]
    group.twitter_traceability = params[:twitter_traceability] if params[:twitter_traceability]
    group.introduction = params[:introduction] if params[:introduction]
    group.public = params[:public] if params[:public]

    unless group.valid?
      render json: { "code": 400, "message": group.errors.messages }, status: :bad_request
      return
    end

    unless group.save
      render json: { "code": 500, "message": 'グループを編集できませんでした。' }, status: :internal_server_error
      return
    end

    render json: group.json
  end

  # rubocop:enable Metrics/AbcSize
end
