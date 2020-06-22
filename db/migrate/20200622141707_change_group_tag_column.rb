class ChangeGroupTagColumn < ActiveRecord::Migration[6.0]
  def change
    add_index :group_tags, [:tag_id, :group_id], unique: true
  end
end
