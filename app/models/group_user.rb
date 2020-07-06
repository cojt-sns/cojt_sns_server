class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :group_id }

  def json
    {
      "id": id,
      "name": name,
      "group_id": group_id,
      "user_id": user.private ? nil : user_id,
      "image": user.image_url
    }
  end
end
