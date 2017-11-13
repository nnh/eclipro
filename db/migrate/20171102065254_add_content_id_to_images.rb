class AddContentIdToImages < ActiveRecord::Migration[5.1]
  def change
    add_reference :images, :content, index: true
  end
end
