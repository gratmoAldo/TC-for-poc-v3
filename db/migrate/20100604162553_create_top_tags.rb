class CreateTopTags < ActiveRecord::Migration
  def self.up
    create_table :top_tags do |t|
      t.integer :tag_id
      t.integer :asset_id
      t.integer :counter, :default => 0
      t.timestamps
    end
  end
  
  def self.down
    drop_table :top_tags
  end
end
