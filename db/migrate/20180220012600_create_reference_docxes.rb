class CreateReferenceDocxes < ActiveRecord::Migration[5.1]
  def change
    create_table :reference_docxes do |t|
      t.references :protocol, foreign_key: true

      t.timestamps
    end
  end
end
