class CreateUserTags < ActiveRecord::Migration[6.0]
  def change
    create_table :users_tags do |t|
      t.integer :user_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
