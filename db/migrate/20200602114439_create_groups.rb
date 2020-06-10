class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.boolean :public, default: true, null: false
      t.boolean :twitter_traceability, default: false, null: false
      t.text :questions
      t.boolean :introduction, default: false, null: false

      t.timestamps
    end
  end
end
