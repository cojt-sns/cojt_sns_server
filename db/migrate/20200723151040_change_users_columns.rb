class ChangeUsersColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :email, :string, null: true
  end

  def down
    change_column :users, :email, :string, null: false
  end

  def change
    remove_index :users, column: [:email]
  end
end
