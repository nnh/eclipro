class AddCommentsCountToContents < ActiveRecord::Migration[5.1]
  def self.up
    add_column :contents, :comments_count, :integer, null: false, default: 0

    Content.all.each do |content|
      content.comments_count = content.comments.size
      content.save
    end
  end

  def self.down
    remove_column :contents, :comments_count
  end
end
