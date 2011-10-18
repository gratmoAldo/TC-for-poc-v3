class ForcesController < ApplicationController
  # GET /forces
  # GET /forces.xml
  def index
    @forces = Force.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forces }
    end
  end

  # GET /forces/1
  # GET /forces/1.xml
  def show
    @force = Force.last

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        res = {:authorization => "OAuth #{@force.authorization}"} #, :server_base => @force.serverBase}
        render :json => res
      }
    end
  end

  # GET /forces/new
  # GET /forces/new.xml
  def new
    @force = Force.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @force }
    end
  end

  # GET /forces/1/edit
  def edit
    @force = Force.find(params[:id])
  end

  # POST /forces
  # POST /forces.xml
  def create
    @force = Force.new(params[:force])

    respond_to do |format|
      if @force.save
        format.html { redirect_to(@force, :notice => 'Force was successfully created.') }
        format.xml  { render :xml => @force, :status => :created, :location => @force }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @force.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forces/1
  # PUT /forces/1.xml
  def update
    @force = Force.find(params[:id])

    respond_to do |format|
      if @force.update_attributes(params[:force])
        format.html { redirect_to(@force, :notice => 'Force was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @force.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forces/1
  # DELETE /forces/1.xml
  def destroy
    @force = Force.find(params[:id])
    @force.destroy

    respond_to do |format|
      format.html { redirect_to(forces_url) }
      format.xml  { head :ok }
    end
  end
end
