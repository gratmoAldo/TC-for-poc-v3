class SiteMessagesController < ApplicationController
  # GET /site_messages
  # GET /site_messages.xml
  def index
    @site_messages = SiteMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_messages }
    end
  end

  # GET /site_messages/1
  # GET /site_messages/1.xml
  def show
    @site_message = SiteMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_message }
    end
  end

  # GET /site_messages/new
  # GET /site_messages/new.xml
  def new
    @site_message = SiteMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_message }
    end
  end

  # GET /site_messages/1/edit
  def edit
    @site_message = SiteMessage.find(params[:id])
  end

  # POST /site_messages
  # POST /site_messages.xml
  def create
    @site_message = SiteMessage.new(params[:site_message])

    respond_to do |format|
      if @site_message.save
        flash[:notice] = 'SiteMessage was successfully created.'
        format.html { redirect_to(@site_message) }
        format.xml  { render :xml => @site_message, :status => :created, :location => @site_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_messages/1
  # PUT /site_messages/1.xml
  def update
    @site_message = SiteMessage.find(params[:id])

    respond_to do |format|
      if @site_message.update_attributes(params[:site_message])
        flash[:notice] = 'SiteMessage was successfully updated.'
        format.html { redirect_to(@site_message) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_messages/1
  # DELETE /site_messages/1.xml
  def destroy
    @site_message = SiteMessage.find(params[:id])
    @site_message.destroy

    respond_to do |format|
      format.html { redirect_to(site_messages_url) }
      format.xml  { head :ok }
    end
  end
end
