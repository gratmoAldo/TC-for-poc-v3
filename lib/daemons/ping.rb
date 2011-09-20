#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development" # "production"

require File.dirname(__FILE__) + "/../../config/environment"
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

sleep_time = 62 # seconds

def ping_site(url)
  begin
    tmp = open(url) { |f| f.read }
    ActiveRecord::Base.logger.info "#{Time.now} Successfully hit #{url}"
  rescue
    ActiveRecord::Base.logger.info "#{Time.now} *** Failed to access #{url}"
  end
end

while($running) do
  
  # Replace this with your code

  # ping_site("http://localhost/product_hub_v1/login")
  ping_site("http://localhost/content_hub_v3/login")
  # ping_site("http://localhost/bank")
  # ping_site("http://localhost/page_hub")
  # ping_site("http://localhost/products/login")
  
  ActiveRecord::Base.logger.info "#{Time.now} Pausing for #{sleep_time} seconds...\n"

  sleep sleep_time
end
ActiveRecord::Base.logger.info "ping daemon stopped"
