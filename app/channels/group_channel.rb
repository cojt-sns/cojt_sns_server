class GroupChannel < ApplicationCable::Channel
  def subscribed
    logger.info("hoge")
    # group = Group.find_by(id: params[:id])
    stream_from "group_1"
    
    # if group.nil?
    #   return reject
    # end

    # if group.public
    #   return stream_from "group_#{params[:id]}"
    # end

    # auth = AuthenticateToken.find_by(token: params[:token])
    # if !auth.nil? && auth.active && auth.created_at > Time.zone.now - 1.hour
    #   return stream_from "group_#{params[:id]}" if auth.user.groups.ids.include?(group.id)
    #   return reject
    # else
    #   return reject
    # end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end