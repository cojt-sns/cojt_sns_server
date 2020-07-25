class Notification < ApplicationRecord
  belongs_to :user

  def json
    {
      "id": id,
      "content": content,
      "url": url
    }
  end
end
