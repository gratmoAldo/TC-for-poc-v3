class CreateServiceRequests < ActiveRecord::Migration
  def self.up
    create_table :service_requests do |t|
      t.integer :sr_number
      t.string :title
      t.integer :severity
      t.string :status
      t.string :product
      t.text :description
      t.datetime :next_action_at
      t.integer :site_id
      t.integer :contact_id
      t.integer :escalation
      t.integer :owner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :service_requests
  end
end
