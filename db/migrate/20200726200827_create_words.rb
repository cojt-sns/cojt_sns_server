class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.string :word, null: false
      t.string :word_class, null: false
    end
  end
end
