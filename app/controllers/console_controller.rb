class ConsoleController < ApplicationController
  
  before_filter :admin_only
  # skip_before_filter :verify_authenticity_token

  def index
    @subscriptions = Subscription.find :all, :order => 'subscriptions.updated_at DESC', :limit => 20
    @last_apn_notifications = APN::Notification.find :all, :order => 'apn_notifications.created_at DESC', :limit => 10
    @last_apn_devices = APN::Device.find :all, :order => 'apn_devices.last_registered_at DESC', :limit => 10
    
    @last_c2dm_notifications = C2dm::Notification.find :all, :order => 'c2dm_notifications.created_at DESC', :limit => 10
    @last_c2dm_devices = C2dm::Device.find :all, :order => 'c2dm_devices.last_registered_at DESC', :limit => 10



=begin


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


=end




    respond_to do |format|
      format.html # index.html.erb
      format.mobile
      # format.xml  { render :xml => @subscriptions }
      # format.json  { render :json => @subscriptions }
    end
  end
end
