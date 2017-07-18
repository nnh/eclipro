class CreateContents < ActiveRecord::Migration[5.1]
  def change
    create_table :contents do |t|
      t.references :protocol, foreign_key: true
      t.references :section, foreign_key: true
      t.text :body
      t.integer :status

      t.timestamps
    end
  end
end
