class AddSerialToServiceRequests < ActiveRecord::Migration
  def self.up
    add_column :service_requests, :serial, :string
  end

  def self.down
    remove_column :service_requests, :serial
  end
end
