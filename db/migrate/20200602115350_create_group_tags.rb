class CreateGroupTags < ActiveRecord::Migration[6.0]
  def change
    create_table :group_tags do |t|
      t.references :group, foreign_key: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
