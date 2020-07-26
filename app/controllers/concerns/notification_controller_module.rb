module NotificationControllerModule
  def create_notification(target_user, content, url = nil, image = nil)
    notification = Notification.new(content: content, url: url, image: image)
    notification.user = target_user
    return unless notification.save

    ActionCable.server.broadcast("notification_#{target_user.id}", notification.json)
  end
end
