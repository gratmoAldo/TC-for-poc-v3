class AddVersionAndHandlingToServiceRequest < ActiveRecord::Migration
  def self.up
    add_column :service_requests, :version, :string
    add_column :service_requests, :handling, :string
  end

  def self.down
    remove_column :service_requests, :handling
    remove_column :service_requests, :version
  end
end
