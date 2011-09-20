# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110919184331) do

  create_table "admins", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apn_apps", :force => true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "apn_device_groupings", :force => true do |t|
    t.integer "group_id"
    t.integer "device_id"
  end

  add_index "apn_device_groupings", ["device_id"], :name => "index_apn_device_groupings_on_device_id"
  add_index "apn_device_groupings", ["group_id", "device_id"], :name => "index_apn_device_groupings_on_group_id_and_device_id"
  add_index "apn_device_groupings", ["group_id"], :name => "index_apn_device_groupings_on_group_id"

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

  create_table "apn_group_notifications", :force => true do |t|
    t.integer  "group_id",          :null => false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apn_group_notifications", ["group_id"], :name => "index_apn_group_notifications_on_group_id"

  create_table "apn_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "apn_pull_notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "launch_notification"
  end

  create_table "assets", :force => true do |t|
    t.string   "sid"
    t.string   "source"
    t.string   "xid"
    t.string   "da_type"
    t.string   "da_subtype"
    t.integer  "entitlement_model"
    t.integer  "entitlement_value"
    t.integer  "popularity",        :default => 0
    t.integer  "avg_rating",        :default => 0
    t.integer  "bookmarks_count",   :default => 0
    t.datetime "published_at"
    t.datetime "expire_at"
    t.boolean  "is_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "asset_id"
    t.string   "title"
    t.text     "note"
    t.boolean  "is_private", :default => false
    t.boolean  "is_system",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "c2dm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "c2dm_devices", ["registration_id"], :name => "index_c2dm_devices_on_registration_id", :unique => true

  create_table "c2dm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key",     :null => false
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "c2dm_notifications", ["device_id"], :name => "index_c2dm_notifications_on_device_id"

  create_table "escalations", :force => true do |t|
    t.integer  "level"
    t.string   "business_impact"
    t.integer  "escalated_by"
    t.datetime "de_escalated_at"
    t.integer  "de_escalated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inbox_srs", :force => true do |t|
    t.integer "inbox_id"
    t.integer "service_request_id"
  end

  create_table "inboxes", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.integer  "asset_id"
    t.string   "url"
    t.string   "locale"
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "created_by"
    t.string   "visibility"
    t.integer  "effort_minutes"
    t.string   "note_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_requests", :force => true do |t|
    t.integer  "sr_number"
    t.string   "title"
    t.integer  "severity"
    t.string   "status"
    t.string   "product"
    t.text     "description"
    t.datetime "next_action_at"
    t.integer  "site_id"
    t.integer  "contact_id"
    t.integer  "escalation"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
  end

  create_table "site_messages", :force => true do |t|
    t.integer  "site_id"
    t.datetime "expires_at"
    t.integer  "created_by"
    t.text     "body"
    t.string   "status"
    t.string   "message_function"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "country"
    t.integer  "site_id"
    t.integer  "account_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "display_id"
    t.string   "token"
    t.string   "notification_method"
    t.integer  "badge"
    t.integer  "sr_severity"
    t.datetime "last_subscribed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "asset_id"
    t.integer "bookmark_id"
  end

  add_index "taggings", ["asset_id"], :name => "index_taggings_on_asset_id"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string   "namespace"
    t.string   "key"
    t.string   "value"
    t.string   "name"
    t.string   "display_name"
    t.integer  "taggings_count", :default => 0
    t.integer  "creator_id"
    t.boolean  "is_reviewed",    :default => false
    t.boolean  "is_approved",    :default => false
    t.integer  "reviewer_id"
    t.datetime "reviewed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["key"], :name => "index_tags_on_key"
  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["namespace"], :name => "index_tags_on_namespace"
  add_index "tags", ["value"], :name => "index_tags_on_value"

  create_table "top_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "asset_id"
    t.integer  "counter",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "top_tags", ["asset_id"], :name => "index_top_tags_on_asset_id"
  add_index "top_tags", ["tag_id"], :name => "index_top_tags_on_tag_id"

  create_table "translations", :force => true do |t|
    t.integer  "asset_id"
    t.string   "locale"
    t.string   "source_locale"
    t.string   "title"
    t.string   "short_title"
    t.text     "abstract"
    t.string   "thumbnail_s"
    t.string   "thumbnail_m"
    t.string   "thumbnail_l"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translations", ["asset_id"], :name => "index_translations_on_asset_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.integer  "role",          :default => 4
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "timezone",      :default => "Pacific Time (US & Canada)"
    t.string   "password_hash"
    t.string   "password_salt"
    t.integer  "reputation",    :default => 1
    t.string   "locale",        :default => "en_US"
    t.boolean  "is_admin",      :default => false
    t.boolean  "is_deleted",    :default => false
    t.integer  "access_level",  :default => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
