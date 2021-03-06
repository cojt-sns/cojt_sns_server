class Group < ApplicationRecord
  acts_as_tree

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users, allow_destroy: true

  has_many :group_words, dependent: :destroy
  has_many :words, through: :group_words
  accepts_nested_attributes_for :group_words, allow_destroy: true

  has_many :posts, dependent: :destroy

  validates :name, format: { with: %r{\A[^\.\#@/\\]+\z} }
  validate :same_hierarchy_same_name
  validate :ancestors_same_name

  def fullname
    names = ancestors.map(&:name).reverse
    names << name
    names.join('.')
  end

  def member
    users.count
  end

  # JSONを返す
  def json
    {
      "id": id,
      "name": name,
      "parent_id": parent_id,
      "fullname": fullname,
      "member": member,
      "frequency": frequency,
      "depth_score": depth_score,
      "independency": independency,
      "score": score
    }
  end

  def json_with_children(descendants)
    res = json
    res['children'] = []
    res['children'] = children.map { |group| group.json_with_children(descendants - 1) } if descendants != 0
    res
  end

  # validates

  # 兄弟タグに同名タグが存在するか
  def same_hierarchy_same_name
    errors.add(:name, '同階層に同名グループが存在します') if siblings.find { |t| t.name == name }.present?
  end

  # 祖先に同名タグが存在するか
  def ancestors_same_name
    errors.add(:name, '祖先に同名グループが存在します') if ancestors.find { |t| t.name == name }.present?
  end
end
