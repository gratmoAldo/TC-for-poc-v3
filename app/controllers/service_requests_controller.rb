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
        render :xml => @service_requests 
      }
      format.json  { 
        res = {
          :service_requests => @service_requests.map { |sr| sr.to_hash(:role => session[:role], :user_id => session[:user_id], :format => :summary) }, 
          :meta => {
            :created_at => Time.now,
            :server_name => request.server_name,
            :user => current_user.fullname,
            :environment => ENV["RAILS_ENV"]
          }
        }
        logger.info "res = #{res.inspect}"
        render :json => res
      }
    end
  end

  # GET /service_requests/1
  # GET /service_requests/1.xml
  def show
    @service_request = ServiceRequest.lookup(params[:id])
    
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

      # create a flag everytime a user accesses the SR details
      @service_request.mark_as_read_by_user(current_user)
              
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html {
          @watchers = User.watching_sr @service_request.id
          myinbox = Inbox.owned_by(current_user).first
          sr_id = @service_request.id
          @inbox_sr = InboxSr.find(:first, :conditions => ["service_request_id=? and inbox_id=?",sr_id,myinbox]) || @service_request.inbox_srs.new(:inbox => myinbox)

          @notes = Note.recent(@service_request.id, session[:role])
          @new_note = @service_request.notes.new :created_by => current_user.id, :effort_minutes => 1, :note_type => "Research", :visibility => Note::VISIBILITY_PUBLIC
        }# show.html.erb
        format.mobile #{ render :text => request.user_agent }
        format.xml  { render :xml => @service_request }
        format.json { 
          res = {
            :service_request => @service_request.to_hash(:role => session[:role], :user_id => current_user.id, :format => :complete),
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
        logger.info "Adding a note during SR update via controller - should be in model?????"
        
        
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
end
