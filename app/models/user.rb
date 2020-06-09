class User < ApplicationRecord
  has_secure_password
  has_one_attached :image

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :tags
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :posts, dependent: :destroy
  has_many :authenticate_tokens, dependent: :nullify

  validate :email, -> {
    unless self.email =~ /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
      self.errors.add(:email, "メールアドレスが適切でありません")
    end
  }

  def json
    {
      "id": id,
      "name": name,
      "bio": bio,
      "image": Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true),
    }
  end
end
