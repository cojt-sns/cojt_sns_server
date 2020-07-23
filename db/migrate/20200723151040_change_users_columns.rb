class ChangeUsersColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :email, :string, null: true
    remove_index :users, column: [:email]
  end
end
