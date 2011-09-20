class TagsController < ApplicationController
  before_filter :admin_only, :only => [:new, :create, :update, :destroy]

  def index
    @tags = Tag.paginate :per_page => params[:per_page]||25, :page => params[:page], :order => "tags.namespace, tags.key, tags.value"
  end
  
  def show
    @tag = Tag.lookup(params[:id])
    if @tag.nil?
      flash[:error] = "Tag <em>#{params[:id]}</em> does not exist"
      redirect_to tags_url
    else
      @bookmarks = Bookmark.find :all, :order => "assets.xid", :include => [:asset, :user], :joins => :taggings, :conditions => {:taggings => {:tag_id => @tag.id}}
      asset_ids = @bookmarks.map(&:asset_id).uniq
      @user_tag_cloud = TopTag.for_assets(asset_ids).user_tags.sum(:counter, :group => :tag_id)
      @machine_tag_cloud = TopTag.for_assets(asset_ids).machine_tags.sum(:counter, :group => :tag_id)      
    end
  end
  
  def new
    @tag = Tag.new
  end
  
  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      flash[:notice] = "Successfully created tag."
      redirect_to @tag
    else
      render :action => 'new'
    end
  end
  
  def edit
    @tag = Tag.find(params[:id])
  end
  
  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Successfully updated tag."
      redirect_to @tag
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    flash[:notice] = "Successfully destroyed tag."
    redirect_to tags_url
  end
end
