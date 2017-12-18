class CreateParticipations < ActiveRecord::Migration[5.1]
  def change
    create_table :participations do |t|
      t.references :user
      t.references :protocol
      t.integer :role, null: false, default: 0
      t.integer :sections, array: true, default: []

      t.timestamps
    end
  end
end
