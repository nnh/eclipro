class AddSeqToSection < ActiveRecord::Migration[5.1]
  def up
    add_column :sections, :seq, :integer, null: false, default: 0
    add_column :contents, :seq, :integer, null: false, default: 0

    Section.all.each do |section|
      no = section.no
      section.update_columns(no: no.split('.')[0], seq: no.split('.')[1].to_i || 0)
    end

    Content.all.each do |content|
      no = content.no
      content.update_columns(no: no.split('.')[0], seq: no.split('.')[1].to_i || 0)
    end

    change_column :sections, :no, 'integer USING CAST(no AS integer)', null: false, default: 0
    change_column :contents, :no, 'integer USING CAST(no AS integer)', null: false, default: 0
  end

  def down
    remove_column :sections, :seq
    remove_column :contents, :seq
    change_column :sections, :no, :string
    change_column :contents, :no, :string
  end
end
