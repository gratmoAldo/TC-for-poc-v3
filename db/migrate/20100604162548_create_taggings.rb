class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.integer :tag_id
      # t.integer :user_id
      t.integer :asset_id
      t.integer :bookmark_id
      # t.datetime :created_at
    end
  end
  
  def self.down
    drop_table :taggings
  end
end
