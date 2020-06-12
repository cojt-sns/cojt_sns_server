class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def json
    {
      "id": id,
      "content": content,
      "user_id": user_id,
      "group_id": group_id,
      "created_at": created_at
    }
  end
end
