class CreateAdmin < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.string :key
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :admins
  end
end
