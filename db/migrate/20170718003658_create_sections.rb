class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.string :no
      t.string :title
      t.text :template
      t.text :description
      t.text :example

      t.timestamps
    end
  end
end
