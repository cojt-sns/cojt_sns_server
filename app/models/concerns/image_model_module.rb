module ImageModelModule
  DEFAULT_IMAGE_PATH = '/default.png'.freeze

  def image_url
    if image.present?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      DEFAULT_IMAGE_PATH
    end
  end
end
