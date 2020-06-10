class GroupTag < ApplicationRecord
  belongs_to :tag
  belongs_to :group
end
