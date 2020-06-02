class Tag < ApplicationRecord
  acts_as_tree

  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups
end
