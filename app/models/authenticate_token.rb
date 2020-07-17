class AuthenticateToken < ApplicationRecord
  belongs_to :user

  def check
    res = active && last_access > Time.zone.now - 1.hour

    return false unless res

    return false unless update(last_access: DateTime.now)

    true
  end
end
