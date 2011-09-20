class TaggingsController < ApplicationController
  before_filter :admin_only

  def index
    @taggings = Tagging.all
  end
  
  def show
    @tagging = Tagging.find(params[:id])
  end
  
  def new
    @tagging = Tagging.new
  end
  
  def create
    @tagging = Tagging.new(params[:tagging])
    if @tagging.save
      flash[:notice] = "Successfully created tagging."
      redirect_to @tagging
    else
      render :action => 'new'
    end
  end
  
  def edit
    @tagging = Tagging.find(params[:id])
  end
  
  def update
    @tagging = Tagging.find(params[:id])
    if @tagging.update_attributes(params[:tagging])
      flash[:notice] = "Successfully updated tagging."
      redirect_to @tagging
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @tagging = Tagging.find(params[:id])
    @tagging.destroy
    flash[:notice] = "Successfully destroyed tagging."
    redirect_to taggings_url
  end
end
