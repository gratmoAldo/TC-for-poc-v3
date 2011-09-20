class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :name
      t.string :address
      t.string :country
      t.integer :site_id
      t.integer :account_number

      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
