class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index "translations", ["asset_id"], :name => "index_translations_on_asset_id"
    add_index "tags", ["key"], :name => "index_tags_on_key"
    add_index "tags", ["namespace"], :name => "index_tags_on_namespace"
    add_index "tags", ["value"], :name => "index_tags_on_value"
    add_index "tags", ["name"], :name => "index_tags_on_name"
    add_index "taggings", ["asset_id"], :name => "index_taggings_on_asset_id"
    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "top_tags", ["tag_id"], :name => "index_top_tags_on_tag_id"
    add_index "top_tags", ["asset_id"], :name => "index_top_tags_on_asset_id"
  end

  def self.down
    remove_index :top_tags, :asset_id
    remove_index :top_tags, :tag_id
    remove_index :taggings, :tag_id
    remove_index :taggings, :asset_id
    remove_index :tags, :name
    remove_index :tags, :value
    remove_index :tags, :namespace
    remove_index :tags, :key
    remove_index :translations, :asset_id
  end
end
