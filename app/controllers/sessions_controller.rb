class SessionsController < ApplicationController
  def new
    @administrators = User.active_admin :order => 'users.username'
    @employees      = User.active_normal.employees :order => 'users.username'
    @partners       = User.active_normal.partners :order => 'users.username'
    @customers      = User.active_normal.customers :order => 'users.username'
  end
  
  def create
    user = login params[:login], params[:password]
    if user
      flash[:notice] = "Logged in successfully."
      if admin?
        redirect_to_target_or_default(root_url)
      else
        redirect_to_target_or_default(myinbox_url)
      end
    else
      flash[:error] = "Invalid login or password."
      redirect_to login_path
    end
  end
  
  def destroy
    logout
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end
end
