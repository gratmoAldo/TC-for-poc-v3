class InboxSrsController < ApplicationController
  # def new
  #   @user = User.new
  # end
  
  def create
    myinbox = Inbox.owned_by(current_user).first
    sr = ServiceRequest.find_by_id params[:inbox_sr][:service_request_id]
    inbox_sr = InboxSr.find(:first, :conditions => ["service_request_id=? and inbox_id=?",sr,myinbox])
    
    logger.info "Found inbox_sr #{inbox_sr.inspect} for sr id#{sr.inspect} and myinbox #{myinbox.inspect}"
    unless inbox_sr
      inbox_sr = InboxSr.create(:service_request => sr, :inbox => myinbox)
    end
        
    respond_to do |format|
      if inbox_sr.valid?
        flash[:notice] = 'You are now watching this Service Request.'
        format.html { redirect_to sr }
      else
        flash[:error] = 'You are now watching this Service Request.'
        format.html { redirect_to sr }
      end
    end
  end
  
  
  
  def destroy
    myinbox = Inbox.owned_by(current_user).first
    inbox_sr = InboxSr.find(:first, :conditions => ["id=? and inbox_id=?",params[:id],myinbox])
    if inbox_sr
      sr = ServiceRequest.find_by_id inbox_sr[:service_request_id]
      inbox_sr.destroy
      logger.info "found sr=#{sr.inspect}"
    else
      logger.info "inbox_sr not found"
    end
    redirect_to service_request_path(sr)    
  end
end
