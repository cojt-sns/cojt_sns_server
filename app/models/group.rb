class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users, allow_destroy: true

  has_many :group_tags, dependent: :destroy
  has_many :tags, through: :group_tags
  accepts_nested_attributes_for :group_tags, allow_destroy: true

  has_many :posts, dependent: :destroy

  validates :tags, presence: true
  validate :same_tags
  validate :same_ancestor_tags
  validate :unique_tags

  # JSONを返す
  def json
    {
      "id": id,
      "public": public,
      "twitter_traceability": twitter_traceability,
      "questions": questions.split('$'),
      "introduction": introduction,
      "tags": tags.pluck(:id)
    }
  end

  # validate

  # タグが重複しているか
  def unique_tags
    errors.add(:tags, 'タグが重複しています') if tags.uniq(&:id).size < tags.size
  end

  # 同じタグを持つグループが存在するか
  def same_tags
    groups = Group.where.not(id: id)
    groups.each do |group|
      if group.tags.map(&:id).sort == tags.map(&:id).sort
        errors.add(:tags, '同じタグを持つグループが存在します')
        return
      end
    end
  end

  # 祖先が重複するタグを持っているか
  def same_ancestor_tags
    tags.each do |tag|
      if tag.ancestors.any? { |t| tags.include?(t) }
        errors.add(:tags, '祖先が重複するタグが存在します')
        return
      end
    end
  end
end
