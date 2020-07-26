class Notification < ApplicationRecord
  belongs_to :user

  def json
    {
      "id": id,
      "content": content,
      "url": url,
      "image": image,
      "created_at": created_at
    }
  end
end
