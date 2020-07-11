class GroupChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find_by(id: params[:id])

    return reject if group.nil?

    return stream_from "group_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
