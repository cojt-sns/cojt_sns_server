class ChangeAuthenticateTokensColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :authenticate_tokens, :last_access, :datetime
  end
end
