class CreatePrincipalInvestigatorUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :principal_investigator_users do |t|
      t.references :protocol, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
