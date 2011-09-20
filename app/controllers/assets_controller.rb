class AssetsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :update, :destroy]
  before_filter :login_optional, :only => [:index, :show]
  
  # ORDER_BY = ['translations.title', 'assets.']
  def index
    # @assets = Asset.with_locale(@locale).paginate :page => params[:page], :per_page => 10
    
    @assets = nil
    @keywords = (params[:search]||'').split(' ')

    conditions = {}
    conditions[:sid]=params[:i].split(',') if params[:i]
    
    @assets = Asset.with_locale(@locale).with_access(@access_level).with_fulltext(@keywords).sort_by_popularity.paginate :conditions => conditions, :page => params[:page], :per_page=>12#, :include => :tags

    logger.info "Found #{@assets.count} assets"

    if @assets.empty? and @assets.total_pages > 0
      logger.info "Found no assets, redirecting to assets_path"
      redirect_to assets_path 
    else
      respond_to do |format|
        format.html { # index.html.erb
          logger.info "Replying HTML (assets)"        
        }
        format.xml {
          logger.info "Replying XML (assets)"
          if conditions[:sid]
            tmp = {}; @assets.each { |asset| tmp[asset.sid] = asset}
            @assets = conditions[:sid].map { |sid| tmp[sid]}.compact
          end
        }# { render :xml => @assets.to_xml(:include => {:asset => {:include => {:mappings => {:include => :release}}}})}
        format.json { render :json => @assets } # "assets/index.xml.builder"}
      end
    end
    
  end
  
  def show
    @asset = Asset.lookup params[:id]
    if @asset.nil? then
      headers["Status"] = "404 Not Found"
      flash[:error]="Asset #{params[:id]} not found"
      redirect_to assets_url
    else
      @locales = @asset.locales
      if params[:id] != @asset.to_param
        headers["Status"] = "301 Moved Permanently"
        redirect_to asset_url(@asset.to_param)
      end
    end
  end
  
  def new
    @asset = Asset.new
    @asset.translations.build :locale => 'en_US'
    3.times { @asset.links.build }
  end
  
  def create
    @asset = Asset.new(params[:asset])
    if @asset.save
      flash[:notice] = "Successfully created asset."
      redirect_to @asset
    else
      render :action => 'new'
    end
  end
  
  def edit
    @asset = Asset.lookup params[:id]
    if @asset.nil? then
      headers["Status"] = "404 Not Found"
      flash[:error]="Document #{params[:id]} not found"
      redirect_to assets_url
    else
      @translations = @asset.translations
      if params[:id] != @asset.to_param
        headers["Status"] = "301 Moved Permanently"
        redirect_to edit_asset_url(@asset.to_param)
      end
    end
  end
  
  def update
    @asset = Asset.lookup params[:id]
    if @asset.nil? then
      headers["Status"] = "404 Not Found"
      flash[:error]="Document #{params[:id]} not found"
      redirect_to assets_url
    else
      if @asset.update_attributes(params[:asset])
        respond_to do |format|
          format.html { 
            flash[:notice] = "Successfully updated asset."
            redirect_to assets_url 
          }
          format.js
        end
      else
        respond_to do |format|
          format.html {render :action => 'edit'}
          format.js {render :action => 'edit'}
        end
      end
    end
  end
  
  def destroy
    @asset = Asset.lookup params[:id]
    if @asset.mark_as_deleted
      flash[:notice] = "Successfully deleted asset."
    end
    redirect_to assets_url
  end
  
  def recover
    @asset = Asset.lookup params[:id]
    if @asset.recover
      flash[:notice] = "Successfully recovered asset."
    end
    redirect_to assets_url
  end
  
end
