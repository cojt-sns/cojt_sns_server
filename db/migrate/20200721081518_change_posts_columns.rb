class ChangePostsColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :parent_id, :integer
    add_column :posts, :image, :string
  end
end
