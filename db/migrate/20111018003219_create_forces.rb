class CreateForces < ActiveRecord::Migration
  def self.up
    create_table :forces do |t|
      t.string :authorization
      t.string :serverBase

      t.timestamps
    end
  end

  def self.down
    drop_table :forces
  end
end
