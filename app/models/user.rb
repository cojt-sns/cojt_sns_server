class User < ApplicationRecord
  has_secure_password
  has_one_attached :image

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :groups, dependent: :destroy
  has_and_belongs_to_many :tags, dependent: :destroy
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :posts, dependent: :destroy
  has_many :authenticate_tokens, dependent: :nullify

  DEFAULT_IMAGE_PATH = '/neko.png'.freeze

  validates :name, presence: true
  validates :email, uniqueness: true

  validate :email, -> {
    unless email =~ %r{^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$}
      errors.add(:email, 'メールアドレスが適切でありません')
    end
  }
  
  validate :groups, -> {
    unless groups.ids.count == groups.ids.uniq.count
      errors.add(:groups, 'グループが重複しています')
    end
  }

  def json
    {
      "id": id,
      "name": name,
      "bio": bio.presence || '',
      "image": image_url
    }
  end

  def image_url
    if image.present?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      DEFAULT_IMAGE_PATH
    end
  end
end
