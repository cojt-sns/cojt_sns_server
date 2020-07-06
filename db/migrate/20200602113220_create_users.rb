class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.text :bio
      t.string :email, null: false
      t.string :password_digest
      t.string :image
      t.string :oauth_token
      t.string :oauth_token_secret
      t.boolean :private, default: false, null: false

      t.timestamps
      t.index [:email], unique: true
    end
  end
end
