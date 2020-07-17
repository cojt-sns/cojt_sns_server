class GroupsController < ApplicationController
  include ImageControllerModule

  before_action :authenticate, only: %i(create update join leave)
  # rubocop:disable Metrics/AbcSize

  # get /groups
  def index
    or_ = false

    if params[:descendants].present? && (!params[:descendants].match(/(-1|[0-9]+)/) || params[:descendants].to_i < -1)
      render json: { "code": 400, "message": 'descendantsの指定が不適切です。' }, status: :bad_request
      return
    end

    descendants = params[:descendants].present? ? params[:descendants].to_i : 0

    if params[:name].nil?
      groups = Group.all
      groups = Group.where(parent_id: nil) if descendants == -1
      render json: groups.map { |group| group.json_with_children(descendants) }
      return
    end

    or_ = params[:or] if params[:or] == 'true'

    names = params[:name].split(' ')
    groups = Group
    if !or_
      groups = Group.all
      names.each do |name|
        groups = groups.where('name like ?', "%#{name}%")
      end
    else
      groups = Group.none
      names.each do |name|
        groups = groups.or(Group.where('name like ?', "%#{name}%"))
      end
    end

    render json: groups.map { |group| group.json_with_children(descendants) }
  end

  # rubocop:eable Metrics/AbcSize

  # post /groups
  def create
    ActiveRecord::Base.transaction do
      group = Group.new(group_params)

      group.save!

      # ログインユーザをグループに追加
      group_user = GroupUser.new
      group_user.user = @user
      group_user.group = group
      group_user.admin = true
      group_user.name = @user.name

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

    render json: group.json
  end

  # put /groups/{id}
  def update
    group = Group.find_by(id: params[:id])

    # グループが存在しない場合のエラー
    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    group_user = group.group_users.where(user: @user, admin: true)
    if group_user.nil?
      render json: { "code": 403, "message": '管理者でないため、更新できませんでした。' }, status: :forbidden
      return
    end

    group.attributes = group_params

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
    group = Group.find_by(id: params[:id])

    if group.nil?
      render json: { "code": 404, "message": '該当するグループが存在しません。' }, status: :not_found
      return
    end

    if group.users.include?(@user)
      render json: { "code": 400, "message": 'すでにこのグループに参加しています。' }, status: :bad_request
      return
    end

    group_user = GroupUser.new(group_user_params)
    group_user.user = @user
    group_user.group = group
    set_image(group_user, params['image'].to_io, "#{@user.id}_#{Time.zone.now}") if params['image'].present?

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

    group_user = group.group_users.find_by(user_id: @user.id)
    if group_user.nil?
      render json: { "code": 400, "message": 'このグループには参加していません' }, status: :bad_request
      return
    end

    unless group_user.destroy
      render json: { "code": 500, "message": 'グループからの脱退に失敗しました' }, status: :internal_server_error
      return
    end

    render json: { "code": 200, "message": 'successful operation' }
  end

  private

  def group_user_params
    params.permit(:name)
  end

  def group_params
    params.permit(:name, :parent_id)
  end
end
