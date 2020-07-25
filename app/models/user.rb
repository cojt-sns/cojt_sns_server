class User < ApplicationRecord
  include ImageModelModule

  has_secure_password
  has_one_attached :image

  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users
  has_many :notifications
  accepts_nested_attributes_for :group_users, allow_destroy: true

  has_many :authenticate_tokens, dependent: :nullify

  validates :name, presence: true

  validate :email, -> {
    return if email.blank?

    unless email =~ %r{^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$}
      errors.add(:email, 'メールアドレスが適切でありません')
    end
    error.add(:email, 'メールアドレスが既に登録されています') if User.where.not(id: id).where(email: email).exists?
  }

  validate :groups, -> {
    errors.add(:groups, 'グループが重複しています') unless groups.ids.count == groups.ids.uniq.count
  }

  def json
    {
      "id": id,
      "name": name,
      "private": private,
      "bio": bio.presence || '',
      "image": image_url
    }
  end
end
