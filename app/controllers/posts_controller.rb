class PostsController < ApplicationController
  before_action :authenticate, only: %i(update destroy group create show)
  
  # get /posts
  def index
    params = posts_params
    posts = Post.content_like(params["content"])
                .created_day_range(until_day: params["until"], since: params["since"])
                .created_time_range(until_timestamp: params["until_timestamp"], since_timestamp: params["since_timestamp"])
                .from_user(params["from"])
                .limit(params["max"])

    render json: posts.map{ |post| post.json }.to_json
  end

  # get /groups/:id/public/posts
  def public_group
    render json: [
      {
        "id": 1,
        "content": "こんにちは！",
        "user_id": 1,
        "group_id": 1,
        "created_at": "2020-06-09T09:20:52.220Z"
      }
    ]
  end

  # get /groups/:id/posts
  def group
    render json: [
      {
        "id": 1,
        "content": "こんにちは！",
        "user_id": 1,
        "group_id": 1,
        "created_at": "2020-06-09T09:20:52.220Z"
      }
    ]
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
    params.permit(:content, :from, :since, :until, :since_timestamp, :until_timestamp, :max)
  end
end
