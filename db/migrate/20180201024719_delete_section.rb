class DeleteSection < ActiveRecord::Migration[5.1]
  def change
    Section.where(no: ['title', 'compliance']).destroy_all
    Content.where(no: ['title', 'compliance']).destroy_all
  end
end
