class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :namespace
      t.string :key
      t.string :value
      t.string :name
      t.string :display_name
      t.integer :taggings_count, :default => 0
      t.integer :creator_id
      t.boolean :is_reviewed, :default => false
      t.boolean :is_approved, :default => false
      t.integer :reviewer_id
      t.datetime :reviewed_at
      t.timestamps
    end
  end
  
  def self.down
    drop_table :tags
  end
end
