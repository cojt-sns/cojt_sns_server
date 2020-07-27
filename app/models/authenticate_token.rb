class AuthenticateToken < ApplicationRecord
  belongs_to :user

  def check
    res = active && last_access > Time.zone.now - 12.hours

    return false unless res

    return false unless update(last_access: DateTime.now)

    true
  end
end
