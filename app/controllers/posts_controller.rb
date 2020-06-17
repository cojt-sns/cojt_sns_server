class PostsController < ApplicationController
  before_action :authenticate, only: %i(update destroy group create show)

  # get /posts
  def index
    params = posts_params
    posts = basic_search(params, Post.all)

    render json: posts.map(&:json).to_json
  end

  # get /posts/{id}
  def show
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: 'Bad Request' }, status: :bad_request
      return
    end

    post = Post.find_by(id: params[:id])

    if post.nil?
      render json: { code: '404', message: '存在しない投稿です' }, status: :not_found
      return
    end

    unless post.group.users.where(id: @user&.id).exists?
      render json: { "code": 403, "message": '不正なアクセスです・' }, status: :forbidden
      return
    end

    render json: post.json
  end

  # put /posts/{id}
  def update
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: 'Bad Request' }, status: :bad_request
      return
    end

    post = Post.find_by(id: params[:id])

    if post.nil?
      render json: { code: '404', message: '存在しない投稿です' }, status: :not_found
      return
    end

    unless @user == post.user
      render json: { "code": 403, "message": '投稿者でなければ、編集できません' }, status: :forbidden
      return
    end

    post.content = params[:content]

    unless post.save
      render json: { "code": 500, "message": '更新できませんでした。' }, status: :internal_server_error
      return
    end

    ActionCable.server.broadcast("group_#{post.group.id}", update: post.json)

    render json: post.json
  end

  # delete /posts/{id}
  def destroy
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: 'Bad Request' }, status: :bad_request
      return
    end
    post = Post.find_by(id: params[:id])

    if post.nil?
      render json: { code: '404', message: '存在しない投稿です' }, status: :not_found
      return
    end

    unless @user == post.user
      render json: { "code": 403, "message": '投稿者でなければ、投稿を消去できません' }, status: :forbidden
      return
    end

    unless post.destroy
      render json: { "code": 500, "message": '投稿の削除に失敗しました' }, status: :internal_server_error
      return
    end

    render json: post.json, status: :ok
  end

  # get /groups/:id/public/posts
  def public_group
    params = posts_params
    group = Group.find_by(id: params[:id])

    if group.blank?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: :not_found
      return
    end

    unless group.public
      render json: { "code": 403, "message": 'パブリックグループではありません' }, status: :bad_request
      return
    end

    posts = basic_search(params, Post.where(group_id: group.id))

    render json: posts.map(&:json).to_json
  end

  # get /groups/:id/posts
  def group
    params = posts_params
    group = Group.find_by(id: params[:id])
    if group.blank?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: :not_found
      return
    end

    # approvable_ids = User.where.ids
    # puts "\n\n\n\n"
    # puts "groups: "
    # puts @user.groups.ids
    # puts "\n\n\n\n"
    unless @user.groups.ids.include?(group.id)
      render json: { "code": 403, "message": 'グループへの権限がありません' }, status: :forbidden
      return
    end

    posts = basic_search(params, Post.where(group_id: params['id']))

    render json: posts.map(&:json).to_json
  end

  # post /groups/:id/posts
  def create
    params = posts_params
    group = Group.find_by(id: params[:id])
    if group.blank?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: :not_found
      return
    end

    unless @user.groups.ids.include?(group.id)
      render json: { "code": 403, "message": 'グループへの権限がありません' }, status: :forbidden
      return
    end

    post = Post.new
    post.content = params[:content]
    post.user = @user
    post.group = group

    unless post.save
      render json: { "code": 500, "message": '投稿できませんでした。' }, status: :internal_server_error
      return
    end

    ActionCable.server.broadcast("group_#{group.id}", new: post.json)

    render json: post.json
  end

  private

  def posts_params
    params.permit(:id, :content, :from, :since, :until, :since_timestamp, :until_timestamp, :max)
  end

  def basic_search(search_params, posts)
    posts.content_like(search_params['content'])
         .created_day_range(until_day: search_params['until'], since: search_params['since'])
         .created_time_range(until_timestamp: search_params['until_timestamp'],
                             since_timestamp: search_params['since_timestamp'])
         .from_user(search_params['from'])
         .limit(search_params['max'])
  end
end
