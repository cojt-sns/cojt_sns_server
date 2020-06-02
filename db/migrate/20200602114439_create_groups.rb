class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.boolean :public
      t.boolean :twitter_traceability
      t.text :questions
      t.boolean :introduction

      t.timestamps
    end
  end
end
