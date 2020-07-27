class ChangeWordsColumns < ActiveRecord::Migration[6.0]
  def change
    add_index :words, :word, unique: true
  end
end
