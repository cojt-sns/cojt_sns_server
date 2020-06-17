class AuthenticateToken < ApplicationRecord
  belongs_to :user

  def check
    active && created_at > Time.zone.now - 1.hour
  end
end
