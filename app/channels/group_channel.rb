class GroupChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find_by(id: params[:id])

    return reject if group.nil?

    return stream_from "group_#{params[:id]}" if group.public

    auth = AuthenticateToken.find_by(token: params[:token])
    return stream_from "group_#{params[:id]}" if !auth.nil? && auth.check && auth.user.groups.ids.include?(group.id)

    reject
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
