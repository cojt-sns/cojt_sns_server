class Post < ApplicationRecord
  belongs_to :group
  belongs_to :group_user

  delegate :user, to: :group_user

  def json
    {
      "id": id,
      "content": content,
      "group_user_id": group_user_id,
      "group_id": group_id,
      "created_at": created_at
    }
  end

  scope :content_like, ->(value) {
    where('content LIKE ?', "%#{value}%") if value.present?
  }

  scope :from_group_user, ->(from_group_user_id) {
    where(user_id: from_group_user_id) if from_group_user_id.present?
  }

  #
  # created_at から時間を含めて絞る
  # (引数の形式） 2020-6/13 01:34:56
  # until_timestamp: created_at <= since_timestamp
  # since_timestamp: created_at >= since_timestamp
  #
  scope :created_time_range, ->(until_timestamp: nil, since_timestamp: nil) {
    return if until_timestamp.blank? && since_timestamp.blank?

    if until_timestamp.present? && since_timestamp.present?
      created_since = Time.zone.parse(since_timestamp)
      created_until = Time.zone.parse(until_timestamp)
      where(created_at: created_since..created_until)

    elsif since_timestamp.present?
      created_since = Time.zone.parse(since_timestamp)
      where(created_at: created_since..)

    elsif until_timestamp.present?
      created_until = Time.zone.parse(until_timestamp)
      where(created_at: ..created_until)
    end
  }
  #
  # created_at から日付のみで絞る
  # 引数の形式: 2020-6/13
  #
  scope :created_day_range, ->(until_day: nil, since: nil) {
    return if until_day.blank? && since.blank?

    if until_day.present? && since.present?
      created_since = Time.zone.parse(since)
      created_until = all_day(Time.zone.parse(until_day))
      where(created_at: created_since..created_until)

    elsif since.present?
      created_since = Time.zone.parse(since)
      where(created_at: created_since..)

    elsif until_day.present?
      created_until = all_day(Time.zone.parse(until_day))
      where(created_at: ..created_until)
    end
  }

  def self.all_day(day)
    (day + 1.day) - 1.second
  end
end
