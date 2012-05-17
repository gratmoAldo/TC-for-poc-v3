class InboxSrsController < ApplicationController
  before_filter :login_required
  
  # def new
  #   @user = User.new
  # end
  
  def create
    # myinbox = Inbox.owned_by(current_user).first
    sr = ServiceRequest.find_by_id params[:inbox_sr][:service_request_id]
    # inbox_sr = InboxSr.find(:first, :conditions => ["service_request_id=? and inbox_id=?",sr,myinbox])
    # 
    # logger.info "Found inbox_sr #{inbox_sr.inspect} for sr id#{sr.inspect} and myinbox #{myinbox.inspect}"
    # unless inbox_sr
    #   inbox_sr = InboxSr.create(:service_request => sr, :inbox => myinbox)
    # end

    inbox_sr = sr.watch(current_user)
    
    respond_to do |format|
      if inbox_sr.valid?
        format.html { 
          flash[:notice] = 'You are now watching this Service Request.'
          redirect_to sr 
        }
        format.json { 
          render :json => { :inbox_sr_id => inbox_sr.id }, :status => :created
        }
      else
        errors = inbox_sr.errors.full_messages.join('; ') if inbox_sr
        logger.info "Failed to watch with id #{params[:inbox_sr][:service_request_id]} failed. Error was #{errors}"
        format.html { 
          flash[:error] = 'Failed to watch this Service Request'
          redirect_to sr 
        }
        format.json { 
          render :json => {:error => errors, :status => :unprocessable_entity }, :status => :unprocessable_entity 
        }
      end
    end
  end
  
  
  
  def destroy
    myinbox = Inbox.owned_by(current_user).first
    sr = nil
    
    inbox_sr = InboxSr.find(:first, :conditions => ["id=? and inbox_id=?",params[:id],myinbox])

    # look for the sr only if user is not customer or agent
    if inbox_sr
      sr = ServiceRequest.find_by_id inbox_sr[:service_request_id]
    end
    
    if sr.nil? ||sr.contact_id == session[:user_id] || sr.owner_id == session[:user_id]
      sr = nil
    end

    respond_to do |format|
      if inbox_sr && sr
        inbox_sr.destroy
        format.html { 
          flash[:notice] = 'You stopped watching this Service Request.'
          redirect_to sr 
        }
        format.json { 
          render :json => {}, :status => :ok
        }
      else
        format.html { 
          flash[:error] = 'Cannot unwatch this Service Request'
          redirect_to sr 
        }
        format.json { 
          render :json => {:status => :unprocessable_entity }, :status => :unprocessable_entity 
        }
      end
    end
  end
end
