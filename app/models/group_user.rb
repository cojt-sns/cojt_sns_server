class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :name, presence: true
  validates :user_id, uniqueness: { scope: :group_id }

  validate :answers_count

  def json
    {
      "id": id,
      "name": name,
      "answers": answers.split('$'),
      "introduction": introduction,
      "group_id": group_id,
      "user_id": group.visible_profile||user_id==@user.id ? user_id : nil,
      "image": user.image_url
    }
  end

  def answers_count
    errors.add(:answers, '回答が不十分です。') unless group.questions.count('$') == answers.count('$')
  end
end
