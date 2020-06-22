class GroupTag < ApplicationRecord
  belongs_to :tag
  belongs_to :group

  validates :tag_id, uniqueness: {scope: :group_id}
end
