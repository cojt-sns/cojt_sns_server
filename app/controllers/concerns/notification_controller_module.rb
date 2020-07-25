module NotificationControllerModule
  def create_notification(target_user, content, url = nil, image = nil)
    notification = Notification.new(content: content, url: url)
    notification.user = target_user
    return unless notification.save

    ActionCable.server.broadcast("notification_#{target_user.id}",
                                 content: notification.content,
                                 url: notification.url,
                                 id: notification.id,
                                 image: image)
  end
end
