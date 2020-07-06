class Group < ApplicationRecord
  acts_as_tree

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users, allow_destroy: true

  has_many :posts, dependent: :destroy

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
end
