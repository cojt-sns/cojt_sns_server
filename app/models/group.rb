class Group < ApplicationRecord
  #include ActiveModel::Validations

  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags

  has_many :posts
  validate :tags_valid?
  
  def tags_valid?
    groups=Group.all
    groups.each do |group|
      if group.tags==self.tags
        errors.add(:tags,'内容が不正です。')
      end
    end
  end
end