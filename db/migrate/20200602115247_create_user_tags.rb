class CreateUserTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags_users do |t|
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
