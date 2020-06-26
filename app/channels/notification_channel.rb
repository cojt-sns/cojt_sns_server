class NotificationChannel < ApplicationCable::Channel
  def subscribed
    user = User.find_by(id: params[:id])

    return reject if user.nil?

    stream_from "notification_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
