class CreateAttachments < ActiveRecord::Migration[5.1]
  def up
    create_table :attachments do |t|
      t.string  :data_file_name, null: false, index: true
      t.string  :data_content_type
      t.integer :data_file_size

      t.integer :parent_id
      t.string  :parent_type, :limit => 30
      t.string  :type, :limit => 30

      # Uncomment	it to save images dimensions, if your need it
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
    add_index :attachments, [:parent_type, :type, :parent_id], name: 'index_parent_type'
    add_index :attachments, [:parent_id, :parent_type]
  end

  def down
    drop_table :attachments
  end
end
