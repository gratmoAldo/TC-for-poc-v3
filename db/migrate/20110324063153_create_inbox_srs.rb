class CreateInboxSrs < ActiveRecord::Migration
  def self.up
    create_table :inbox_srs do |t|
      t.integer :inbox_id
      t.integer :service_request_id
    end
  end

  def self.down
    drop_table :inbox_srs
  end
end
