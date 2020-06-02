class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.text :bio
      t.string :email
      t.string :password_digest
      t.string :icon_url
      t.string :oauth_token
      t.string :oauth_token_secret

      t.timestamps
    end
  end
end
