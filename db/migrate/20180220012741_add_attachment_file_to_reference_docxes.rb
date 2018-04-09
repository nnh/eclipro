class AddAttachmentFileToReferenceDocxes < ActiveRecord::Migration[5.1]
  def self.up
    change_table :reference_docxes do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :reference_docxes, :file
  end
end
