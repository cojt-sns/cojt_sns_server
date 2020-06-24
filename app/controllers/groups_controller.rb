class GroupsController < ApplicationController
  before_action :authenticate, only: %i(create update join leave)

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

  # rubocop:eable Metrics/AbcSize

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
      if question.empty?
        render json: { "code": 400, "message": '質問が空です。' }, status: :bad_request
        return
      elsif question.include?('$')
        render json: { "code": 400, "message": '質問事項に「$」を含めないでください。' }, status: :bad_request
        return
      end
    end

    ActiveRecord::Base.transaction do
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

      group.visible_profile = params[:visible_profile] unless params[:visible_profile].nil?
      group.introduction = params[:introduction] unless params[:introduction].nil?
      group.public = params[:public] unless params[:public].nil?

      group.save!

      # ログインユーザをグループに追加
      group_user = GroupUser.new
      group_user.answers = params[:questions].length > 1 ? '$' * (params[:questions].length - 1) : ''
      group_user.user = @user
      group_user.group = group
      group_user.admin = true

      group_user.save!

      render json: group.json
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { "code": 500, "message": e.record.errors.messages }, status: :internal_server_error
  end

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

  # put /groups/{id}
  def update
    unless params[:questions].is_a?(Array)
      render json: { "code": 400, "message": '質問事項は配列で入力してください。' }, status: :bad_request
      return
    end

    params[:questions]&.each do |question|
      if question.empty?
        render json: { "code": 400, "message": '質問が空です。' }, status: :bad_request
        return
      elsif question.include?('$')
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

    unless group.users.ids.include?(@user.id)
      render json: { "code": 403, "message": 'メンバーでないため、更新できませんでした。' }, status: :forbidden
      return
    end

    if params[:questions]
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
    end
    group.questions = params[:questions].join('$') if params[:questions]
    group.visible_profile = params[:visible_profile] unless params[:visible_profile].nil?
    group.introduction = params[:introduction] unless params[:introduction].nil?
    group.public = params[:public] unless params[:public].nil?

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

  # post /groups/:id/join
  def join
    unless params[:answers].is_a?(Array)
      render json: { "code": 400, "message": '回答は配列で入力してください。' }, status: :bad_request
      return
    end

    params[:answers].each do |answer|
      if answer.include?('$')
        render json: { "code": 400, "message": '回答に「$」を含めないでください。' }, status: :bad_request
        return
      end
    end

    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    if group.users.include?(user)
      render json: { "code": 400, "message": 'すでにこのグループに参加しています。' }, status: :bad_request
      return
    end

    unless group.public
      render json: { "code": 403, "message": 'このグループには参加できません' }, status: :forbidden
      return
    end

    group_user = GroupUser.new
    group_user.answers = params[:answers].join('$')
    group_user.user = @user
    group_user.group = group

    unless group_user.valid?
      render json: { "code": 400, "message": group_user.errors.messages }, status: :bad_request
      return
    end

    unless group_user.save
      render json: { "code": 500, "message": 'グループに参加できませんでした。' }, status: :internal_server_error
      return
    end

    render json: { "code": 200, "message": 'successful operation' }
  end

  # rubocop:enable Metrics/AbcSize

  # post /groups/:id/leave
  def leave
    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    unless group.users.include?(@user)
      render json: { "code": 400, "message": 'このグループには参加していません' }, status: :bad_request
      return
    end

    group.users.delete(@user)

    unless group.save
      render json: { "code": 500, "message": 'このグループから脱退できませんでした' }, status: :internal_server_error
      return
    end
    render json: { "code": 200, "message": 'successful operation' }
  end
end
