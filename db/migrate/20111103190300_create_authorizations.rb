class CreateAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :authorizations do |t|
      t.boolean :is_confirmed
      t.string :device_name
      t.string :device_model
      t.string :device_token
      t.string :validation_token
      t.integer :user_id
      t.datetime :activated_at
      t.datetime :last_used_at

      t.timestamps
    end
    
    add_index "authorizations", ["device_token"], :name => "index_authorizations_on_device_token"
    add_index "authorizations", ["validation_token"], :name => "index_authorizations_on_validation_token"

  end

  def self.down
    remove_index :authorizations, :validation_token
    remove_index :authorizations, :device_token
    drop_table :authorizations
  end
end
