class GroupUser < ApplicationRecord
  include ImageModelModule

  belongs_to :group
  belongs_to :user
  has_one_attached :image

  has_many :posts, dependent: :nullify

  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :group_id }

  validate :image, -> {
    if image.present?
      if image.blob.byte_size > 10.megabytes
        image.purge
        errors.add(:image, 'ファイルサイズが大きすぎます')
      elsif !%w(image/jpg image/jpeg image/gif image/png).include?(image.blob.content_type)
        image.purge
        errors.add(:image, 'アップロードされたファイルは画像ファイルではありません')
      end
    end
  }

  def json
    {
      "id": id,
      "name": name,
      "group_id": group_id,
      "user_id": user.private ? nil : user_id,
      "image": image_url,
      "admin": admin
    }
  end

  def image_url
    if image.present?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      return DEFAULT_IMAGE_PATH if user.private

      user.image_url
    end
  end
end
