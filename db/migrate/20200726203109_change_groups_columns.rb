class ChangeGroupsColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :frequency, :float
    add_column :groups, :depth_score, :float
    add_column :groups, :independency, :float
    add_column :groups, :score, :float
  end
end
