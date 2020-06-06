class Group < ApplicationRecord
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :posts, dependent: :destroy
end
