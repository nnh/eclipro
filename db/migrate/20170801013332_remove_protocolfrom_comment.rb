class RemoveProtocolfromComment < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :comments, :protocols
    remove_reference :comments, :protocol, index: true
    remove_foreign_key :comments, :sections
    remove_reference :comments, :section, index: true
    add_reference :comments, :content, foreign_key: true
  end
end
