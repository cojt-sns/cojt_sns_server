class GroupUser < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :user_id, uniqueness: { scope: :group_id }

  validate :answers_count

  def answers_count
    errors.add(:answers, '回答が不十分です。') unless group.questions.count('$') == answers.count('$')
  end
end
