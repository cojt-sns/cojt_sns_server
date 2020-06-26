class NotificationChannel < ApplicationCable::Channel
  def subscribed
    auth = AuthenticateToken.find_by(token: params[:token])

    return reject if auth.nil?

    stream_from "notification_#{auth.user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
