class MyinboxController < ApplicationController
  before_filter :login_required

  def index
    logger.info "inside MyinboxController/index - format = #{request[:format]}"
    @myinbox = Inbox.owned_by(current_user).first    
    
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
            :myinbox => @service_requests.map { |sr| sr.to_hash(:role => session[:role], :user_id => session[:user_id], :format => :summary) }, 
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


end
