class AddClosedAtToServiceRequest < ActiveRecord::Migration
  def self.up
    add_column :service_requests, :closed_at, :datetime
  end

  def self.down
    remove_column :service_requests, :closed_at
  end
end
