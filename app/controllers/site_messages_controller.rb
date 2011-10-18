class SiteMessagesController < ApplicationController

  before_filter :login_required
  skip_before_filter :verify_authenticity_token

  # GET /site_messages
  # GET /site_messages.xml
  def index
    
    if admin?
      logger.info "YOU ARE AN ADMIN"
      site = nil
      @site_messages = SiteMessage.recent(nil, session[:role])
    else
      site = Site.find_by_site_id params[:site_id]
      if site.nil?
        @site_messages = nil
      else
        @site_messages = SiteMessage.recent(site, session[:role])
      end
        
    end

    respond_to do |format|
      if site.nil? && @site_messages.nil?
        logger.info "NO SITE and NO MESSAGES"
        # format.html { render :text => request.user_agent }
        format.html {
          flash[:error]="Site #{params[:site_id]} not found"
          redirect_to root_url
        }
        format.xml {
          render :text  => "<error>Not Found</error>", :status => "404 Not Found"
        }
        format.json {
          render :text  => "{\"error\":\"Not Found\"}", :status => "404 Not Found"
        }
      else
        logger.info "SITE is #{site.inspect} and MESSAGES are #{@site_messages.inspect}"
        
        format.html # index.html.erb
        format.xml  { render :xml => @site_messages }
        format.json  { 
          res = {
            :site_messages => @site_messages.map { |sr| sr.to_hash }, 
            :meta => {
              :created_at => Time.now,
              :server_name => request.server_name,
              :user => current_user.fullname,
              :site_id => site_id,
              :environment => ENV["RAILS_ENV"]
            }
          }
          logger.info "Site Messages response is #{res.inspect}"
          render :json => res
        }
      end
    end
  end

  # # GET /site_messages/1
  # # GET /site_messages/1.xml
  # def show
  #   @site_message = SiteMessage.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @site_message }
  #   end
  # end
  # 
  # # GET /site_messages/new
  # # GET /site_messages/new.xml
  # def new
  #   @site_message = SiteMessage.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @site_message }
  #   end
  # end
  # 
  # # GET /site_messages/1/edit
  # def edit
  #   @site_message = SiteMessage.find(params[:id])
  # end
  # 
  # # POST /site_messages
  # # POST /site_messages.xml
  # def create
  #   @site_message = SiteMessage.new(params[:site_message])
  # 
  #   respond_to do |format|
  #     if @site_message.save
  #       flash[:notice] = 'SiteMessage was successfully created.'
  #       format.html { redirect_to(@site_message) }
  #       format.xml  { render :xml => @site_message, :status => :created, :location => @site_message }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @site_message.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # PUT /site_messages/1
  # # PUT /site_messages/1.xml
  # def update
  #   @site_message = SiteMessage.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @site_message.update_attributes(params[:site_message])
  #       flash[:notice] = 'SiteMessage was successfully updated.'
  #       format.html { redirect_to(@site_message) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @site_message.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /site_messages/1
  # # DELETE /site_messages/1.xml
  # def destroy
  #   @site_message = SiteMessage.find(params[:id])
  #   @site_message.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(site_messages_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
