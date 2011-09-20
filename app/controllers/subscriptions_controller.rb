class SubscriptionsController < ApplicationController

  before_filter :login_required, :only => :update
  before_filter :admin_only, :except => :update

  skip_before_filter :verify_authenticity_token

  # PUT /subscriptions/1.json
  def update

    errors = nil

    # Set default values
    form = (params[:subscription] || {}).reverse_merge!(:sr_severity => 1)

    form[:badge] = 0 # initially, there is no badge
    form[:user_id] = current_user.id

    token, display_id = parse_id(params[:id] || "")
    form[:notification_method], form[:display_id] = parse_display_id(display_id)
    errors ||= "Invalid display ID #{display_id}" if form[:notification_method].nil?
    errors ||= "Invalid environment" unless params[:env] == ENV["RAILS_ENV"]

    if errors.nil? # so far so good?
      if token.blank? # new device, see if display_id exists
        conditions = ["display_id = ?", form[:display_id]]
      else # else, lookup by token only
        conditions = ["token = ?", token]
      end
      logger.info "conditions=#{conditions.inspect}"

      @subscription = Subscription.find(:first, :conditions => conditions)
      logger.info "Found subscription #{@subscription.inspect} for token=#{token} / display=#{form[:display_id]}"

      if @subscription
        @subscription.update_attributes(form)
      else
        if token.blank? # no existing subscription and no token, that's a new one
          @subscription = Subscription.new(form)
        else # else, that's an error
          errors ||= "Invalid token "
        end
      end
    end if

    logger.info ">>>>>>> Subscription before save = #{@subscription.inspect} / errors = #{errors.inspect}"

    respond_to do |format|
      if errors.nil? && @subscription && @subscription.save
        format.json  { 
          logger.info "Subscription successful. Session = #{session.inspect}"
          render :json => {:last_subscribed_at => json_date(@subscription.last_subscribed_at), :token => @subscription.token}
        }
      else
        errors ||= "unprocessable entity"
        errors += ";" + @subscription.errors.full_messages.join('; ') if @subscription
        format.json  { render :json => {:error => errors, :status => :unprocessable_entity }, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to(console_url) }
    end
  end  

  private

  def parse_id(id)
    id =~ /^([0-9A-Fa-f]{40})=(.+)$/
    logger.info "token=#{$1}, display_id=#{$2}"
    $1.nil? ? ["",id] : [$1,$2]
  end

  def parse_display_id(display_id)
    if display_id =~ /^[0-9a-f\-]{71}$/ # APN format
      notification_method = 'apn'
      display_id = display_id.gsub('-', ' ') # massage the id a bit
    elsif display_id =~ /^[\-\_0-9a-z]{119}$/i # C2DM format
      notification_method = 'c2dm'
    else
      notification_method = nil # that's an invalid display_id
    end
    [notification_method, display_id]
  end
end
