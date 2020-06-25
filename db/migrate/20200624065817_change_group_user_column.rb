class ChangeGroupUserColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :group_users, :name, :string, null: false
  end
end
