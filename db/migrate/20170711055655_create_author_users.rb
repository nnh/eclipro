class CreateAuthorUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :author_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
