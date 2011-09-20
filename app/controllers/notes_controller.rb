class NotesController < ApplicationController

  before_filter :login_required, :only => [:create, :update]
  before_filter :admin_only, :except => [:update, :create]

  # skip_before_filter :verify_authenticity_token
     
  # skip_before_filter :verify_authenticity_token
  # GET /notes
  # GET /notes.xml
  def index
    @notes = nil
    @keywords = (params[:search]||'').split(' ')

    @notes = Note.with_fulltext(@keywords).paginate :page => params[:page], :per_page => 5, :order => 'updated_at desc'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  # def new
  #   @new_note = Note.new :created_by => current_user.id, :effort_minutes => 1, :note_type => "Research",
  #   :service_request_id => ServiceRequest.last.id
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { 
  #       logger.info "new note: xml response"
  #       render :xml => @new_note, :status => :new, :location => @new_note }
  #   end
  # end

  # GET /notes/1/edit
  def edit
    @note = Note.find(params[:id])
  end

  # POST /notes
  # POST /notes.xml
  def create
    @note = Note.new(params[:note])
    @note.created_by = current_user.id
    @note.effort_minutes ||= 1
    @note.visibility ||= "Internal"

    logger.info "inside create note with @note=#{@note.inspect}"
    @note.service_request = ServiceRequest.lookup @note.service_request_id
    # logger.info "service_request = #{service_request.inspect}"
    # @note.errors.add(:service_request_id, "must match an existing record") if service_request.nil?
    # logger.info "note error=#{@note.errors.full_messages.join('; ')}"    

    logger.info "Before saving new note. Session = #{session.inspect}"
    
    respond_to do |format|
      if @note.valid? && @note.save

        # TODO need to remove myself from list of watchers
        send_notifications :event => :sr_note_added, :data => {:note => @note},
        :user_ids => @note.service_request.watchers.collect(&:owner_id)

        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_to(@note.service_request) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }  
        format.json { 
          logger.info "AddNote successful. Session = #{session.inspect}"
          render :json => @note, :status => :created
        }      
      else
        errors = @note.errors.full_messages.join('; ') if @note
        logger.info "Failed to save new note! error was #{errors}"
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
        format.json  { 
          logger.info "AddNote error. Session = #{session.inspect}"
          render :json => {:error => errors, :status => :unprocessable_entity }, :status => :unprocessable_entity 
        }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end
end
