class ChangeGroupsUsersToGroupUsers < ActiveRecord::Migration[6.0]
  def change
    rename_table :groups_users, :group_users

    add_column :group_users, :admin, :boolean, default: false, null: false
    add_column :group_users, :answers, :text, null: false
    add_column :group_users, :introduction, :text

    add_index :group_users, [:user_id, :group_id], unique: true
  end
end
