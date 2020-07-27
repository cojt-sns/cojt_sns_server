class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.text :word, null: false
      t.text :word_class, null: false
    end
  end
end
