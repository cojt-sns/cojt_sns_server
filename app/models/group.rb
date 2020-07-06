class Group < ApplicationRecord
  acts_as_tree

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users, allow_destroy: true

  has_many :posts, dependent: :destroy

  validates :name, format: { with: %r{\A[^\.\#@/\\]+\z} }
  validate :same_hierarchy_same_name
  validate :ancestors_same_name

  # JSONを返す
  def json
    {
      "id": id,
      "public": public,
      "visible_profile": visible_profile,
      "questions": questions.split('$'),
      "introduction": introduction,
      "tags": tags.pluck(:id)
    }
  end

  # validates

  # 兄弟タグに同名タグが存在するか
  def same_hierarchy_same_name
    errors.add(:name, '同階層に同名タグが存在します') if siblings.find { |t| t.name == name }.present?
  end

  # 祖先に同名タグが存在するか
  def ancestors_same_name
    errors.add(:name, '祖先に同名タグが存在します') if ancestors.find { |t| t.name == name }.present?
  end
end
