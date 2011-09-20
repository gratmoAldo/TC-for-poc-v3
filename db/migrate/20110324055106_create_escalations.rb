class CreateEscalations < ActiveRecord::Migration
  def self.up
    create_table :escalations do |t|
      t.integer :level
      t.string :business_impact
      t.integer :escalated_by
      t.datetime :de_escalated_at
      t.integer :de_escalated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :escalations
  end
end
