class Public::PostsController < ApplicationController
  # get /public/groups/:id/posts
  def group
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

  private

  def posts_params
    params.permit(:id, :content, :from, :since, :until, :since_timestamp, :until_timestamp, :max)
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
