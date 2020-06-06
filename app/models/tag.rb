class Tag < ApplicationRecord
  acts_as_tree

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users
  has_and_belongs_to_many :groups
  # rubocop:enable Rails/HasAndBelongsToMany

  validates :name, format: { with: /\A[^\.\#@\/\\]+\z/ }
  validate :same_hierarchy_same_name
  validate :ancestors_same_name

  # 先祖タグ名前を結合して返す
  def fullname
    names = self.ancestors.map{|t| t.name}.reverse
    names << self.name
    names.join('.')
  end

  # JSONを返す
  def json
    {
      "id": self.id,
      "name": self.name,
      "parent_id": self.parent_id,
      "fullname": self.fullname
    }
  end

  # validates

  # 兄弟タグに同名タグが存在するか
  def same_hierarchy_same_name
    if self.siblings.find{|t| t.name == self.name}.present?
      errors.add(:name, "同階層に同名タグが存在します")
    end
  end

  # 祖先に同名タグが存在するか
  def ancestors_same_name
    if self.ancestors.find{|t| t.name == self.name}.present?
      errors.add(:name, "祖先に同名タグが存在します")
    end
  end
end
