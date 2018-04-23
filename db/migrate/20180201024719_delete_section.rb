class DeleteSection < ActiveRecord::Migration[5.1]
  def change
    Section.reorder('').where(no: ['title', 'compliance']).destroy_all
    Content.reorder('').where(no: ['title', 'compliance']).destroy_all
  end
end
