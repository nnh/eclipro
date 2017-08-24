class AddReferencesToAuthors < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :author_users, :protocols
    remove_reference :author_users, :protocol, index: true
    remove_foreign_key :reviewer_users, :protocols
    remove_reference :reviewer_users, :protocol, index: true

    add_reference :author_users, :content, index: true
    add_reference :reviewer_users, :content, index: true
  end
end
