class Initial < ActiveRecord::Migration

  def self.up

    create_table "users", :force => true do |t|
      t.string   "firstname"
      t.string   "lastname"
      t.string   "login"
      t.string   "email"
      t.string   "password_hash"
      t.string   "password_salt"
      t.string   "reputation"
      t.string   "locale"
      t.boolean  "is_admin"
      t.integer  "access_level"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "assets", :force => true do |t|
      t.string   "sid"
      t.string   "source"
      t.string   "xid"
      t.string   "da_type"
      t.string   "da_subtype"
      t.integer  "entitlement_model"
      t.integer  "entitlement_value"
      t.integer  "popularity"
      t.integer  "rating"
      t.datetime "published_at"
      t.datetime "expire_at"
      t.boolean  "is_deleted"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    # add_index "assets", ["ft_all_tags"], :name => "index_assets_on_ft_all_tags"

    create_table "tags", :force => true do |t|
      t.string   "namespace"
      t.string   "key"
      t.string   "value"
      t.string   "name"
      t.integer  "creator_id"
      t.boolean  "is_reviewed"
      t.boolean  "is_approved"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "taggings", :force => true do |t|
      t.integer  "tag_id"
      t.integer  "user_id"
      t.integer  "asset_id"
      t.integer  "bookmark_id"
      t.datetime "created_at" # no updated_at
    end

    # add_index "taggings", ["asset_id"], :name => "index_taggings_on_asset_id"
    # add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"

    # add_index "tags", ["key"], :name => "index_tags_on_key"
    # add_index "tags", ["namespace"], :name => "index_tags_on_namespace"
    # add_index "tags", ["value"], :name => "index_tags_on_value"

    create_table "translations", :force => true do |t|
      t.integer  "asset_id"
      t.string   "locale"
      t.string   "title"
      t.string   "short_title"
      t.text     "abstract"
      # t.string   "details"
      t.string   "thumbnail_s"
      t.string   "thumbnail_m"
      t.string   "thumbnail_l"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    # add_index "translations", ["asset_id"], :name => "index_translations_on_asset_id"

    create_table "links", :force => true do |t|
      t.string   "hash"
      t.string   "url"
      t.string   "locale"
      t.string   "format"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end

  def self.down
  end
end
