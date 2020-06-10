class Tag < ApplicationRecord
  acts_as_tree

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :name, format: { with: %r{\A[^\.\#@/\\]+\z} }
  validate :same_hierarchy_same_name
  validate :ancestors_same_name

  # 先祖タグ名前を結合して返す
  def fullname
    names = ancestors.map(&:name).reverse
    names << name
    names.join('.')
  end

  # JSONを返す
  def json
    {
      "id": id,
      "name": name,
      "parent_id": parent_id,
      "fullname": fullname
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
