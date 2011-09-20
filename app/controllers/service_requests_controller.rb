class ServiceRequestsController < ApplicationController

  before_filter :login_required
  skip_before_filter :verify_authenticity_token

  # GET /service_requests
  # GET /service_requests.xml
  def index
    @service_requests = nil
    @keywords = (params[:search]||'').split(' ')

    @service_requests = ServiceRequest.with_fulltext(@keywords).sort_by_sr_number.paginate :page => params[:page], :per_page=>5#, :include => :tags

    logger.info "Found #{@service_requests.count} service_requests"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { 
        # FOR TESTING ONLY
        # dump_model_csv :class => Site, :attribute_list => ["id", "name", "address", "country", "site_id", "account_number", "created_at", "updated_at"]

        render :xml => @service_requests 
      }
      format.json  { 
        render :json => @service_requests 
      }
    end
  end




  # =========================================================== dump_model  
  def dump_model_csv(dump_info)
    c = dump_info[:class]
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
            value = i.send(a).strftime("%Y-%m-%d %H:%M:%S")
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

  # GET /service_requests/1
  # GET /service_requests/1.xml
  def show
    @service_request = ServiceRequest.lookup(params[:id])

    logger.info "Gone fishing..."
    sleep 3
    logger.info "Back"

    if @service_request.nil? then
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html {
          flash[:error]="Service Request #{params[:id]} not found"
          redirect_to inboxes_url
        }
        format.mobile {
          # headers["Status"] = "404 Not Found"
          render :nothing => true, :status => "404 Not Found"
        }
        format.xml {
          render :text  => "<error>Not Found</error>", :status => "404 Not Found"
        }
        format.json {
          render :text  => "{\"error\":\"Not Found\"}", :status => "404 Not Found"
        }
      end
    else
      @watchers = User.watching_sr @service_request.id
      myinbox = Inbox.owned_by(current_user).first
      sr_id = @service_request.id
      @inbox_sr = InboxSr.find(:first, :conditions => ["service_request_id=? and inbox_id=?",sr_id,myinbox]) || @service_request.inbox_srs.new(:inbox => myinbox)
      
      @notes = Note.recent(@service_request.id, session[:role])
      @new_note = @service_request.notes.new :created_by => current_user.id, :effort_minutes => 1, :note_type => "Research"
              
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html # show.html.erb
        format.mobile #{ render :text => request.user_agent }
        format.xml  { render :xml => @service_request }
        format.json { 
          res = {
            :service_request => service_request_to_hash(@service_request, :role => session[:role]), 
            :meta => {
              :created_at => Time.now,
              :server_name => request.server_name,
              :user => current_user.fullname,
              :environment => ENV["RAILS_ENV"]
            }
          }
          
          
          # logger.info "returning JSON response #{res.inspect}"
          render :json => res
          
          }
      end
    end
  end

  # GET /service_requests/new
  # GET /service_requests/new.xml
  def new
    @service_request = ServiceRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_request }
    end
  end

  # GET /service_requests/1/edit
  def edit
    @service_request = ServiceRequest.lookup(params[:id])

    if @service_request.nil? then
      respond_to do |format|
        format.html {
          flash[:error]="Service Request ##{params[:id]} not found"
          redirect_to service_requests_url
        }
      end
    else
      @watchers = User.watching_sr @service_request.id
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html # show.html.erb
        format.mobile #{ render :text => request.user_agent }
        format.xml  { render :xml => @service_request }
      end
    end
  end

  # POST /service_requests
  # POST /service_requests.xml
  def create
    @service_request = ServiceRequest.new(params[:service_request])

    respond_to do |format|
      if @service_request.save
        flash[:notice] = 'ServiceRequest was successfully created.'
        format.html { redirect_to(@service_request) }
        format.xml  { render :xml => @service_request, :status => :created, :location => @service_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_requests/1
  # PUT /service_requests/1.xml
  def update
    @service_request = ServiceRequest.lookup(params[:id])

    respond_to do |format|
      if @service_request.update_attributes(params[:service_request])
        
        @service_request.update_watcher

        if @service_request.escalation > 0      
          send_notifications :event => :sr_escalated, :data => {:service_request => @service_request},
            :user_ids => @service_request.watchers.collect(&:owner_id)
        end
        flash[:notice] = 'ServiceRequest was successfully updated.'
        format.html { redirect_to(@service_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_requests/1
  # DELETE /service_requests/1.xml
  def destroy
    @service_request = ServiceRequest.lookup(params[:id])
    @service_request.destroy

    respond_to do |format|
      format.html { redirect_to(service_requests_url) }
      format.xml  { head :ok }
    end
  end
  
  def service_request_to_hash(sr,options={})    
    options.reverse_merge! :locale => @locale, :keywords => [], :role => User::ROLE_FRIEND
    {
      :sr_number => sr.sr_number,
      :sr_status => sr.status,
      :title => sr.title,
      :problem_description => sr.limited_description,
      :severity => sr.severity,
      :escalation => sr.escalation,
      :product => sr.product,

      :site_name => sr.site.name,
      :site_address => sr.site.address,
      :site_id => sr.site.site_id,

      :contact_name => sr.contact.fullname,
      :contact_email => sr.contact.email,
      :contact_phone1 => sr.contact.phone1,
      :contact_phone2 => sr.contact.phone2,
      :is_contact => sr.contact_id == session[:user_id],

      :owner_name => sr.owner.fullname,
      :owner_email => sr.owner.email,
      :owner_phone1 => sr.owner.phone1,
      :owner_phone2 => sr.owner.phone2,
      :is_owner => sr.owner_id == session[:user_id],

      :nb_notes => sr.notes_count_per_role(options[:role]),
      
      :next_action_at => sr.next_action_at.to_i,
      :last_updated_at => sr.last_updated_at.to_i,
      :created_at => sr.created_at.to_i,
      :closed_at => sr.closed_at.to_i,

      :recent_notes => @notes.collect { |note|
        note_to_hash(note)
      }
    }
  end
  
  def note_to_hash(note,options={})    
    options.reverse_merge! :locale => @locale, :keywords => []
    {      
      :created_at => note.created_at,
      :updated_at => note.updated_at,
      :created_by_name => note.owner.fullname,
      :visibility => note.visibility,
      :effort => note.effort_minutes,
      :note_type => note.note_type,
      :body => note.body
      
    }
  end
end
