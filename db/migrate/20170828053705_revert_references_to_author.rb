class RevertReferencesToAuthor < ActiveRecord::Migration[5.1]
  def change
    # remove_foreign_key :author_users, :contents
    remove_reference :author_users, :content, index: true
    # remove_foreign_key :reviewer_users, :contents
    remove_reference :reviewer_users, :content, index: true

    add_reference :author_users, :protocol, index: true
    add_reference :reviewer_users, :protocol, index: true

    add_column :author_users, :sections, :text
    add_column :reviewer_users, :sections, :text
  end
end
