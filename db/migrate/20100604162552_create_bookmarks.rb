class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.integer :user_id
      t.integer :asset_id
      t.string :title
      t.text :note
      t.boolean :is_private, :default => false
      t.boolean :is_system, :default => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :bookmarks
  end
end
