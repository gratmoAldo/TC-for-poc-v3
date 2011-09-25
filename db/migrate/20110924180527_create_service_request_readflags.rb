class CreateServiceRequestReadflags < ActiveRecord::Migration
  def self.up
    create_table :service_request_readflags do |t|
      t.integer :user_id
      t.integer :service_request_id
    end
  end

  def self.down
    drop_table :service_request_readflags
  end
end
