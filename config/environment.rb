# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require 'thread'
require File.join(File.dirname(__FILE__), 'boot')



Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "fastercsv"
  config.gem "will_paginate"  
  config.gem "apn_on_rails", :version => "0.4.2"
  config.gem "gdata"
  config.gem "c2dm_on_rails"
  
  # config.gem "aws-ses" #, "~> 0.3.2", :require => 'aws/ses'
  # config.gem "mislav-will_paginate", :lib => "will_paginate", :source => "http://gems.github.com"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Pacific Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

begin
  require "will_paginate"
rescue MissingSourceFile => e
  puts e.message
end

begin
  require 'apn_on_rails'
rescue MissingSourceFile => e
  puts e.message
end


begin
  require 'c2dm_on_rails'
rescue MissingSourceFile => e
  puts e.message
end

begin
  require 'aws/ses'
rescue MissingSourceFile => e
  puts e.message
end


DB_STRING_MAX_LENGTH = 255
DB_TEXT_MAX_LENGTH = 40000
HTML_TEXT_FIELD_SIZE = 15

ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| %(<span class="fieldWithErrors">#{html_tag}</span><span class="errorHere"></span>)}
