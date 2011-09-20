class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :service_request_id
      t.integer :created_by
      t.string :visibility
      t.integer :effort_minutes, :default => 1
      t.string :note_type
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
