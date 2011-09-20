class MyinboxController < ApplicationController
  before_filter :login_required

  def index
    logger.info "inside MyinboxController/index - format = #{request[:format]}"
    @myinbox = Inbox.owned_by(current_user).first    

    # logger.info "Gone fishing..."
    # sleep 5
    # logger.info "Back"

    if @myinbox.nil? then
      respond_to do |format|
        headers["Status"] = "404 Not Found"
        format.html {
          flash[:error] = "You don't appear to have an inbox (user id #{current_user})"
          redirect_to root_url
        }
        format.xml {
          render :text  => "<error>Not Found</error>", :status => "404 Not Found"
        }
        format.json {
          render :text  => "{\"error\":\"Not Found\"}", :status => "404 Not Found"
        }
      end
    else
      @service_requests = @myinbox.service_requests
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @service_requests }
        format.json  {
          # render :json => {:inboxes => serialize(@inboxes)} 

          # headers["Content-Type"] = "text/javascript;"
          res = {
            :myinbox => @service_requests.map{  |sr| service_request_summary_hash(sr, :role => session[:role]) }, 
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
  
  def update
    logger.info "inside myinbox.update"
  end

  def destroy
    logger.info "inside myinbox.destroy"
  end

  private

  def service_request_summary_hash(sr,options={})    
    options.reverse_merge! :locale => @locale, :keywords => [], :role => User::ROLE_FRIEND
    
    logger.info "user role is #{options[:role]}"
    {
      :sr_number => sr.sr_number,
      :sr_status => sr.status,
      :title => sr.title,
      :severity => sr.severity,
      :escalation => sr.escalation,
      :product => sr.product,
      :site_name => sr.site.name,
      :nb_notes => sr.notes_count_per_role(options[:role]),
      
      :next_action_at => sr.next_action_at.to_i,
      :last_updated_at => sr.last_updated_at.to_i,
      :created_at => sr.created_at.to_i,
      :closed_at => sr.closed_at.to_i,
      
      :is_contact => sr.contact_id == session[:user_id],
      :is_owner => sr.owner_id == session[:user_id],

      # Deprecated
      :last_updated_in_words => how_old((Time.now - sr.last_updated_at).to_i, :format => :long, :ago => true), #{}"#{1+rand(12)} hours ago",
      :next_action_in_words => how_old((Time.now - sr.next_action_at).to_i, :format => :long, :ago => true),
      :customer => sr.site.name, # renamed to site_name

      # Removed
      # :next_action_in_seconds => (Time.now - sr.next_action_at).to_i,
      # :last_updated_in_seconds => (Time.now - sr.last_updated_at).to_i

    }
  end

end
