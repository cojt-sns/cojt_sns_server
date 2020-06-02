class CreateAuthenticateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :authenticate_tokens do |t|
      t.string :token
      t.integer :user_id
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
