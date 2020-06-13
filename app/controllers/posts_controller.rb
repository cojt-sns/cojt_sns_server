class PostsController < ApplicationController
  before_action :authenticate, only: %i(update destroy group create show)
  
  # get /posts
  def index
    params = posts_params
    posts = basic_search(params, Post.all)

    render json: posts.map{ |post| post.json }.to_json
  end

  # get /groups/:id/public/posts
  def public_group
    params = posts_params
    group = Group.find_by(id: params[:id])

    unless group.present?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: 404
      return 
    end

    unless group.public
      render json: { "code": 403, "message": 'パブリックグループではありません' }, status: :bad_request
      return 
    end

    posts = basic_search(params, Post.where(group_id: group.id))
                
    render json: posts.map{ |post| post.json }.to_json
  end

  # get /groups/:id/posts
  def group
    params = posts_params
    group = Group.find_by(id: params[:id])
    unless group.present?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: 404
      return 
    end

    # approvable_ids = User.where.ids
    # puts "\n\n\n\n"
    # puts "groups: "
    # puts @user.groups.ids
    # puts "\n\n\n\n"
    unless @user.groups.ids.include?(group.id)
      render json: { "code": 403, "message": 'グループへの権限がありません' }, status: 404
      return 
    end

    posts = basic_search(params, Post.where(group_id: params["id"]))
                
    render json: posts.map{ |post| post.json }.to_json
  end

  # post /groups/:id/posts
  def create
    render json: {
      "id": 1,
      "content": "こんにちは！",
      "user_id": 1,
      "group_id": 1,
      "created_at": "2020-06-09T09:20:52.220Z"
    }
  end

  # put /posts/:id
  def update
    render json: {
      "id": 1,
      "content": "こんにちは！",
      "user_id": 1,
      "group_id": 1,
      "created_at": "2020-06-09T09:20:52.220Z"
    }
  end

  # get /posts/:id
  def show
    render json: {
      "id": 1,
      "content": "こんにちは！",
      "user_id": 1,
      "group_id": 1,
      "created_at": "2020-06-09T09:20:52.220Z"
    }
  end

  # delete /posts/:id
  def destroy
    render json: {
      "id": 1,
      "content": "こんにちは！",
      "user_id": 1,
      "group_id": 1,
      "created_at": "2020-06-09T09:20:52.220Z"
    }
  end

  private

  def posts_params
    params.permit(:id, :content, :from, :since, :until, :since_timestamp, :until_timestamp, :max)
  end

  def basic_search(search_params, posts)
    posts = posts.content_like(search_params["content"])
                .created_day_range(until_day: search_params["until"], since: search_params["since"])
                .created_time_range(until_timestamp: search_params["until_timestamp"], since_timestamp: search_params["since_timestamp"])
                .from_user(search_params["from"])
                .limit(search_params["max"])
  end
end
