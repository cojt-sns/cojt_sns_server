class Word < ApplicationRecord
  has_many :group_words, dependent: :destroy
  has_many :groups, through: :group_words

  validates :word, uniqueness: true
end
