class BookmarksController < ApplicationController
  before_filter :admin_only

  def index
    @bookmarks = Bookmark.paginate :per_page => params[:per_page]||15, :page => params[:page], :order => "bookmarks.user_id, bookmarks.asset_id"
  end
  
  def show
    @bookmark = Bookmark.find(params[:id])
  end
  
  def new
    @bookmark = Bookmark.new
  end
  
  def create
    @bookmark = Bookmark.new(params[:bookmark])
    if @bookmark.save
      flash[:notice] = "Successfully created bookmark."
      redirect_to @bookmark
    else
      render :action => 'new'
    end
  end
  
  def edit
    @bookmark = Bookmark.find(params[:id])
  end
  
  def update
    @bookmark = Bookmark.find(params[:id])
    if_found @bookmark do
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = "Successfully updated bookmark."
        redirect_to @bookmark
      else
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    flash[:notice] = "Successfully destroyed bookmark."
    redirect_to bookmarks_url
  end
end
