#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= 'development' # "production"

require File.dirname(__FILE__) + '/../../config/environment'

$running = true
Signal.trap('TERM') do 
  $running = false
end

while($running) do
  ActiveRecord::Base.logger.info 'Push Notification daemon sleeping for 10 seconds...' if ENV["RAILS_ENV"] == 'development'
  sleep 10
  begin
    APN::App.send_notifications
  rescue Exception => e
    ActiveRecord::Base.logger.info "APN::App.send_notifications Exception: #{e.message}"
  end
  
  begin
    C2dm::Notification.send_notifications
  rescue Exception => e
    ActiveRecord::Base.logger.info "C2dm::Notification.send_notifications Exception: #{e.message}"
  end
  
end
ActiveRecord::Base.logger.info "push_notification daemon stopped"
