class CreateSiteMessages < ActiveRecord::Migration
  def self.up
    create_table :site_messages do |t|
      t.integer :site_id
      t.datetime :expires_at
      t.integer :created_by
      t.text :body
      t.string :status
      t.string :message_function

      t.timestamps
    end
  end

  def self.down
    drop_table :site_messages
  end
end
