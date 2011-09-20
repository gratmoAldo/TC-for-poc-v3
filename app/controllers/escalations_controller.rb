class EscalationsController < ApplicationController
  before_filter :admin_only
  # GET /escalations
  # GET /escalations.xml
  def index
    @escalations = Escalation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @escalations }
    end
  end

  # GET /escalations/1
  # GET /escalations/1.xml
  def show
    @escalation = Escalation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @escalation }
    end
  end

  # GET /escalations/new
  # GET /escalations/new.xml
  def new
    @escalation = Escalation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @escalation }
    end
  end

  # GET /escalations/1/edit
  def edit
    @escalation = Escalation.find(params[:id])
  end

  # POST /escalations
  # POST /escalations.xml
  def create
    @escalation = Escalation.new(params[:escalation])

    respond_to do |format|
      if @escalation.save
        flash[:notice] = 'Escalation was successfully created.'
        format.html { redirect_to(@escalation) }
        format.xml  { render :xml => @escalation, :status => :created, :location => @escalation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @escalation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /escalations/1
  # PUT /escalations/1.xml
  def update
    @escalation = Escalation.find(params[:id])

    respond_to do |format|
      if @escalation.update_attributes(params[:escalation])
        flash[:notice] = 'Escalation was successfully updated.'
        format.html { redirect_to(@escalation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @escalation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /escalations/1
  # DELETE /escalations/1.xml
  def destroy
    @escalation = Escalation.find(params[:id])
    @escalation.destroy

    respond_to do |format|
      format.html { redirect_to(escalations_url) }
      format.xml  { head :ok }
    end
  end
end
