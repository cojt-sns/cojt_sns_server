class Tag < ApplicationRecord
  acts_as_tree

  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups

  def fullname
    names = self.ancestors.map{|t| t.name}.reverse
    names << self.name
    names.join('.')
  end
end
