module ImageControllerModule
  def set_image(image_attached_object, image_io, filename)
    image = MiniMagick::Image.read(image_io)
    image.resize '300x300>'
    image_attached_object
      .image
      .attach(
        io: File.open(image.path),
        filename: "#{filename}.#{image.type}",
        content_type: image.mime_type
      )
  end
end
