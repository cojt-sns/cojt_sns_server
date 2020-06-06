class Tag < ApplicationRecord
  acts_as_tree

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups
  # rubocop:enable Rails/HasAndBelongsToMany
end
