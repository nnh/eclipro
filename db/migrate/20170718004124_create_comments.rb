class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :protocol, foreign_key: true
      t.references :section, foreign_key: true
      t.references :user, foreign_key: true
      t.text :body
      t.integer :parent_id
      t.boolean :resolve

      t.timestamps
    end
  end
end
