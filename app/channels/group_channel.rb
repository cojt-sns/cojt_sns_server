class GroupChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find_by(id: params[:id])

    return reject if group.nil?

    return stream_from "group_#{params[:id]}" if group.public

    auth = AuthenticateToken.find_by(token: params[:token])
    if !auth.nil? && auth.active && auth.created_at > Time.zone.now - 1.hour
      return stream_from "group_#{params[:id]}" if auth.user.groups.ids.include?(group.id)

      reject
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
