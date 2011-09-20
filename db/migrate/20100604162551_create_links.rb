class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :asset_id
      t.string :url
      t.string :locale
      t.string :format
      t.timestamps
    end
  end
  
  def self.down
    drop_table :links
  end
end
