class CreateGroupTags < ActiveRecord::Migration[6.0]
  def change
    create_table :group_tags do |t|
      t.integer :group_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
