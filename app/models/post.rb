class Post < ApplicationRecord
  include ImageModelModule

  acts_as_tree
  belongs_to :group
  belongs_to :group_user
  has_one_attached :image

  delegate :user, to: :group_user

  validate :parent_id, -> {
    errors.add(:parent_id, 'スレッドのポストにスレッドを加えることはできません') if tree_level > 1
  }

  validate :image, -> {
    if image.present?
      if image.blob.byte_size > 10.megabytes
        image.purge
        errors.add(:image, 'ファイルサイズが大きすぎます')
      elsif !%w(image/jpg image/jpeg image/gif image/png).include?(image.blob.content_type)
        image.purge
        errors.add(:image, 'アップロードされたファイルは画像ファイルではありません')
      end
    end
  }

  def image_url
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true) if image.present?
  end

  def json
    res = {
      "id": id,
      "content": content,
      "group_user_id": group_user_id,
      "group_id": group_id,
      "image": image_url,
      "created_at": created_at
    }
    res['thread'] = children.map(&:json) if tree_level.zero?
    res['thread_id'] = parent_id unless tree_level.zero?
    res
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
