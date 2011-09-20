# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_content_hub_v3_session',
  :secret      => 'cfa00f2ddc108e966f20333ab1e7b937a62b1a1039710376d19adc5e25491736cef2d72ccd63c4a9059681a61d2001ed051905e9eac3742a62546c45cf2ae5df'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
