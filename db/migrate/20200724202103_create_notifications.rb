class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.text :content
      t.text :url

      t.timestamps
    end
  end
end
