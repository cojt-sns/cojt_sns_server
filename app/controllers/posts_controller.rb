class PostsController < ApplicationController
  before_action :authenticate, only: %i(show update destroy)
  # def new
  # end

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
end
