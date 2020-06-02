class User < ApplicationRecord
  has_secure_password
  
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :tags

  has_many :posts
  has_many :authenticate_tokens
end
