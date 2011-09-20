class TopTagsController < ApplicationController
  before_filter :admin_only

  def index
    @top_tags = TopTag.paginate :per_page => params[:per_page]||25, :page => params[:page]
  end
  
  def show
    @top_tag = TopTag.find(params[:id])
  end
  
  def new
    @top_tag = TopTag.new
  end
  
  def create
    @top_tag = TopTag.new(params[:top_tag])
    if @top_tag.save
      flash[:notice] = "Successfully created top tag."
      redirect_to @top_tag
    else
      render :action => 'new'
    end
  end
  
  def edit
    @top_tag = TopTag.find(params[:id])
  end
  
  def update
    @top_tag = TopTag.find(params[:id])
    if @top_tag.update_attributes(params[:top_tag])
      flash[:notice] = "Successfully updated top tag."
      redirect_to @top_tag
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @top_tag = TopTag.find(params[:id])
    @top_tag.destroy
    flash[:notice] = "Successfully destroyed top tag."
    redirect_to top_tags_url
  end
end
