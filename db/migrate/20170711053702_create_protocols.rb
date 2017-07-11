class CreateProtocols < ActiveRecord::Migration[5.1]
  def change
    create_table :protocols do |t|
      t.string :title, null: false
      t.integer :status, null: false, default: 0
      t.float :version, null: false, default: 0.001

      t.timestamps
    end
  end
end
