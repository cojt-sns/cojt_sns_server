class ChangeUsersColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :email, :string, null: true
    remove_index :users, column: [:email]
  end

  def down
    change_column :users, :email, :string, null: false
    add_index :users, column: [:email], unique: true
  end
end
