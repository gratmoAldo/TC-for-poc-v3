class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :sid
      t.string :source
      t.string :xid
      t.string :da_type
      t.string :da_subtype
      t.integer :entitlement_model
      t.integer :entitlement_value
      t.integer :popularity, :default => 0
      t.integer :avg_rating, :default => 0
      t.integer :bookmarks_count, :default => 0
      t.datetime :published_at
      t.datetime :expire_at
      t.boolean :is_deleted
      t.timestamps
    end
  end
  
  def self.down
    drop_table :assets
  end
end
