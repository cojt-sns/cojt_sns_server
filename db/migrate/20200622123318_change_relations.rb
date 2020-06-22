class ChangeRelations < ActiveRecord::Migration[6.0]
  def change
    add_reference :authenticate_tokens, :user, foreign_key: true

    add_reference :posts, :user, foreign_key: true
    add_reference :posts, :group, foreign_key: true
  end
end
