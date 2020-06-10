class Group < ApplicationRecord
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users
  has_and_belongs_to_many :tags
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :posts, dependent: :destroy

  validate :same_tags
  validate :same_ancestor_tags

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

  # 同じタグを持つグループが存在するか
  def same_tags
    groups = Group.where.not(id: id)
    groups.each do |group|
      if group.tags.map{ |t| t.id }.sort() == tags.map{ |t| t.id }.sort()
        errors.add(:tags, '同じタグを持つグループが存在します')
        return
      end
    end
  end

  # 祖先が重複するタグを持っているか
  def same_ancestor_tags
    tags.each do |tag|
      if tag.ancestors.any?{ |t| tags.include?(t) }
        errors.add(:tags, '祖先が重複するタグが存在します')
        return
      end
    end
  end
end
