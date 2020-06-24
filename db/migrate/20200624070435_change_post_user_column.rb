class ChangePostUserColumn < ActiveRecord::Migration[6.0]
  def change
    remove_reference :posts, :user, foreign_key: true
    add_reference :posts, :group_user, foreign_key: true
  end
end
