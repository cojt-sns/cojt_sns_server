class ChangeGroupColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :groups, :twitter_traceability, :visible_profile
  end
end
