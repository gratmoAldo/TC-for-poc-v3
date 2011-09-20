class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string  :display_id  # uniquely identifies the display
      t.string  :token       # uniquely identifies the subscription
      t.string  :notification_method # method values are: c2dm, apn, email, sms, bps
      t.integer :badge
      t.integer :sr_severity
      t.datetime  :last_subscribed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
