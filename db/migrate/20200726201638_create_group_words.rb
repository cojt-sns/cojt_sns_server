class CreateGroupWords < ActiveRecord::Migration[6.0]
  def change
    create_table :group_words do |t|
      t.references :word, foreign_key: true
      t.references :group, foreign_key: true
    end
  end
end
