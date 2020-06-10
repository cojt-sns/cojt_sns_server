class User < ApplicationRecord
  has_secure_password

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :tags
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :posts, dependent: :destroy
  has_many :authenticate_tokens, dependent: :nullify
end
