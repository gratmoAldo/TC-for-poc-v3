class CreateInboxes < ActiveRecord::Migration
  def self.up
    create_table :inboxes do |t|
      t.string :name
      t.integer :owner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :inboxes
  end
end
