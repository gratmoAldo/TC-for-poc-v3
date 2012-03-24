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
  
  def reset
    ServiceRequestReadflag.destroy_all
    flash[:notice] = "All read / unread flags have been reset."
    
    redirect_to root_url    
  end
  
  def backup_db
    # FOR TESTING ONLY
    dump_model_csv :class => User, :attribute_list => %w(username role firstname lastname email phone1 phone2 timezone password_hash password_salt reputation locale is_admin is_deleted access_level created_at)
    dump_model_csv :class => ServiceRequest, :attribute_list => %w(sr_number severity status next_action_at site_id contact_id escalation owner_id created_at closed_at product version serial title description)
    dump_model_csv :class => Site, :attribute_list => %w(name address country site_id account_number created_at updated_at)
    dump_model_csv :class => Note, :attribute_list => %w(sr_number creator visibility effort_minutes note_type created_at body)
    flash[:notice] = "The database has been successfully backed up to the file system"
    redirect_to root_url    
  end
    
  


  # =========================================================== dump_model  
  def dump_model_csv(dump_info)
    c = dump_info[:class]
    logger.info "dumping data for class #{c}"
    attributes = dump_info[:attribute_list]

    if attributes.nil?
      attributes = ["id"] | c.content_columns.collect(&:name) 
    end

    items = c.find(:all)
    fn = "test/fixtures/" + c.to_s.downcase.pluralize + ".csv"
    f = File.new fn,"w"
    f.write attributes.join(",") + "\n"

    types = {}
    for cols in c.columns
      n = cols.name
      if attributes.include?(n) then
        types[n] = cols.type
      end
    end 

    #    db_type_all = {}

    for i in items
      line = []
      for a in attributes
        db_type = types[a]
        #        puts "a=#{a} - db_type = " + db_type.to_s unless db_type_all.include?(db_type)
        #            db_type_all[db_type] = ""
        if db_type == :boolean then
          if i.send(a) == false then
            value = 0
          else
            value = 1
          end
        else
          #            puts "db_type=#{db_type} for #{a.inspect}"
          if db_type == :datetime then
            #          2007-07-02 14:15:19.0            
            
            value = i.send(a).nil? ? nil : i.send(a).strftime("%Y-%m-%d %H:%M:%S")
          else
            value = i.send(a).to_s.gsub(/["]/, '""')
          end
        end

        line << value
      end
      f.write "\"" + line.join("\",\"") + "\"\n"
    end
    f.close
  end
  
end
