class PostsController < ApplicationController
  include NotificationControllerModule
  before_action :authenticate, only: %i(update destroy create show)
  # get /posts
  def index
    params = posts_params
    posts = basic_search(params, Post.all)

    render json: posts.map(&:json).to_json
  end

  # get /posts/{id}
  def show
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: '不適切なリクエストが行われました' }, status: :bad_request
      return
    end

    post = Post.find_by(id: params[:id])

    if post.nil?
      render json: { code: '404', message: '存在しない投稿です。' }, status: :not_found
      return
    end

    unless post.group.users.where(id: @user&.id).exists?
      render json: { "code": 403, "message": '不正なアクセスです。' }, status: :forbidden
      return
    end

    render json: post.json
  end

  # put /posts/{id}
  def update
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: '不適切なリクエストが行われました' }, status: :bad_request
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
      render json: { "code": 500, "message": '投稿の編集に失敗しました。' }, status: :internal_server_error
      return
    end

    ActionCable.server.broadcast("group_#{post.group.id}", update: post.json)

    render json: post.json
  end

  # delete /posts/{id}
  def destroy
    if params[:id].nil? || params[:id] =~ /[^0-9]+/
      render json: { code: '400', message: '不適切なリクエストが行われました' }, status: :bad_request
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

  # get /groups/:id/posts
  def group
    params = posts_params
    group = Group.find_by(id: params[:id])
    if group.blank?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: :not_found
      return
    end

    posts = basic_search(params, Post.where(group_id: params['id'], parent_id: nil))

    render json: posts.map(&:json).to_json
  end

  # rubocop:disable Metrics/AbcSize
  # post /groups/:id/posts
  def create
    params = posts_params
    group = Group.find_by(id: params[:id])
    if group.blank?
      render json: { "code": 404, "message": 'グループが存在しません' }, status: :not_found
      return
    end

    unless @user.groups.ids.include?(group.id)
      render json: { "code": 403, "message": 'グループに参加していないため、投稿の権限がありません' }, status: :forbidden
      return
    end

    unless params[:thread_id].nil?
      thread = Post.find_by(id: params[:thread_id])
      if thread.nil?
        render json: { "code": 400, "message": 'スレッドがありません' }, status: :not_found
        return
      end

      unless thread.group == group
        render json: { "code": 400, "message": 'スレッドがありません' }, status: :not_found
        return
      end
    end

    post = Post.new
    post.content = params[:content]
    post.group_user = group.group_users.find_by(user_id: @user.id)
    post.group = group
    post.parent_id = params[:thread_id] unless params[:thread_id].nil?
    post.image = params[:image] unless params[:image].nil?

    unless post.save
      render json: { "code": 500, "message": '投稿に失敗しました。' }, status: :internal_server_error
      return
    end

    if post.parent_id.present?
      targets = post.siblings
                    .map(&:group_user)
                    .uniq(&:id)
                    .reject { |g| g.id == post.group_user.id }
      logger.debug(targets.length)
      targets << post.parent.group_user

      targets.each do |target_group_user|
        next unless target_group_user.user_id != @user.id

        post_content = post.parent.content.slice(0..10)
        if post_content.blank?
          post_content = post.parent.content
        else
          post_content += '...'
        end
        content = "\##{group.name}「#{post_content}」に#{post.group_user.name}さんが返信しました。"
        create_notification(target_group_user.user,
                            content,
                            "/groups/#{target_group_user.group.id}",
                            post.group_user.image_url)
      end
    end

    ActionCable.server.broadcast("group_#{group.id}", new: post.json)

    render json: post.json
  end
  # rubocop:enable Metrics/AbcSize

  private

  def posts_params
    params.permit(:id, :content, :from, :since, :until, :since_timestamp, :until_timestamp, :max, :thread_id, :image)
  end

  def basic_search(search_params, posts)
    posts.content_like(search_params['content'])
         .created_day_range(until_day: search_params['until'], since: search_params['since'])
         .created_time_range(until_timestamp: search_params['until_timestamp'],
                             since_timestamp: search_params['since_timestamp'])
         .from_group_user(search_params['from'])
         .limit(search_params['max'])
  end
end
