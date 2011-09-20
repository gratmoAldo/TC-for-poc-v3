class InboxesController < ApplicationController

  before_filter :admin_only
  skip_before_filter :verify_authenticity_token
  # before_filter :admin_only
  
  # GET /inboxes
  # GET /inboxes.xml
  def index
    @inboxes = Inbox.active
    
    # logger.info "Gone finshing..."
    # sleep 3
    # logger.info "I'm back!"
    
    # logger.info "Arming the notification"
    # device = APN::Device.first
    # notification = APN::Notification.create(:device=>device, :badge=>5, :sound=>true, :alert=>"Do you copy? Sent #{DateTime.now}", :custom_properties=>{:sr_number=>34567})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inboxes }
      format.json  {
        # render :json => {:inboxes => serialize(@inboxes)} 

        # headers["Content-Type"] = "text/javascript;"
        res = {
          :inboxes => @inboxes.map{  |inbox| inbox_to_hash(inbox) }, 
          :meta => {
            :page => @page,
            :per_page => @per_page
          }
        }                            
        render :json => res
      }
    end
  end

  # GET /inboxes/1
  # GET /inboxes/1.xml
  def show
    @inbox = Inbox.find_by_id(params[:id])

    if @inbox.nil? then
      respond_to do |format|
        headers["Status"] = "404 Not Found"
        format.html {
          flash[:error] = "Inbox ID #{params[:id]} not found"
          redirect_to inboxes_url
        }
        format.xml {
          render :text  => "<error>Not Found</error>", :status => "404 Not Found"
        }
        format.json {
          render :text  => "{\"error\":\"Not Found\"}", :status => "404 Not Found"
        }
      end
    else
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @inboxes }
        format.json  {
          # render :json => {:inboxes => serialize(@inboxes)} 

          # headers["Content-Type"] = "text/javascript;"
          res = {
            :inboxes => @inboxes.map{  |inbox| inbox_to_hash(inbox) }, 
            :meta => {
              :page => @page,
              :per_page => @per_page
            }
          }                            
          render :json => res
        }
      end
    end

    # respond_to do |format|
    #   format.html # show.html.erb
    #   format.xml  { render :xml => @inbox }
    #   format.json  { 
    #     render :json => { :meta => inbox_to_hash(@inbox),
    #        :service_requests => @inbox.service_requests.map{  |sr| service_request_to_hash(sr) }
    #        }
    #   }
    # end
  end

  private

  def inbox_to_hash(inbox,options={})
    options.reverse_merge! :locale => @locale, :keywords => []
    # { :access_level => asset.access_level, 
    #   :locale => options[:locale],
    #   :da_type => asset.da_type,
    #   :da_subtype => asset.da_subtype,
    #   :published_at => asset.published_at.to_i,
    #   :expire_at => asset.expire_at.to_i,        
    #   :xid => asset.xid,
    #   :title => asset.title(options[:locale]),
    #   :abstract => asset.abstract(options[:locale]),
    #   :hxid => highlight(asset.xid,options[:keywords]),
    #   :htitle => highlight(asset.title(options[:locale]),options[:keywords]),
    #   :habstract => highlight(asset.abstract(options[:locale]),options[:keywords]),
    #   :short_title => asset.short_title(options[:locale]),
    #   :link => asset_url("#{asset.sid}_#{url_friendly(asset.title(@locale))}")
    #    }
    {
      :name => inbox.name,
      :owner_name => inbox.owner.fullname,
      :owner_id => inbox.owner.id,
      :link => inbox_url(inbox)      
    }
  end

end
