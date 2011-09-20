# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication, Notification, ActionView::Helpers::TextHelper

  before_filter :prepare_for_mobile
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  # execute block if object exists, other return 404
  def if_found(obj)
    if obj
      yield 
    else
      render :text => "Not found.", :status => "404 Not Found"
      false
    end    
  end

  private

  # General
  def development?
    ENV["RAILS_ENV"] == "development"
  end
  helper_method :development?


  # Mobile devices
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    case params[:mobile]
    when '-1' # use -1 to clear the session
      session.delete(:mobile_param)
    when '0','1' # forces the view to either desktop or mobile
      session[:mobile_param] = params[:mobile]    
    end
    request.format = :mobile if mobile_device?
  end  

  # Text formatting
  def url_friendly(name='')
    name.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-')
  end

  def highlight(txt, keywords)
    txt ||= ''
    keywords ||= []
    keywords.empty? ? txt : txt.gsub(/(#{keywords.join('|')})/i, '<label class=\'highlight\'>\1</label>')
  end

  SEP = ' ... '
  def mid_truncate(txt, truncation=40)
    txt = txt.to_s
    return txt[0..truncation-1] if truncation < (SEP.length + 2)
    return txt if txt.length <= truncation
    first_chunk_end = ((truncation - SEP.length) / 2).to_i
    second_chunk_start = txt.length - (truncation - SEP.length - first_chunk_end)
    "#{txt[0..first_chunk_end]}#{SEP}#{txt[second_chunk_start..txt.length]}"
  end  

  def how_old(seconds=0, options={})
    options.reverse_merge! :format => :long, :ago => false
    # logger.info "seconds=#{seconds.inspect}"
    seconds = seconds.to_i
    ago = options[:ago] ? " ago" : ""
    if options[:format] == :short
      format = { :minute => "min", :minute => "mns", :hour => "hr", :hours => "hrs", :day => "day", :month => "mo", :months => "mos"}
    else
      format = { :minute => "minute", :hour => "hour", :hours => "hours", :day => "day", :month => "month", :months => "months"}
    end

    if seconds < 60 then # 1 minute
      "just now"
    else
      if seconds < 3600 then # 1 hour
        pluralize((seconds / 60).to_i, format[:minute]) + ago
      elsif seconds < 86400 then # 2 days
        pluralize((seconds / 3600), format[:hour], format[:hours]) + ago
      elsif seconds < 2635200 then # 30 days
        pluralize((seconds / 86400), format[:day]) + ago
      else
        pluralize((seconds / 2635200), format[:month], format[:months]) + ago
      end
    end
  end
  
  def short_date(d)    
    do_date(d,"%D %l:%M%p")
  end

  def simple_date(d)    
    do_date(d,"%m/%d/%Y %I:%M %p %Z")
  end

  def full_date(d)
    do_date(d,"%m/%d/%Y %r %Z")
  end

  def json_date(d)
    do_date(d,"%m/%d/%Y %H:%M:%S %Z")
  end

  def do_date(d,f)
    d.nil? ? "" : d.strftime(f)
  end


  
  helper_method :url_friendly, :highlight, :mid_truncate, :how_old, :short_date, :simple_date, :full_date, :json_date
end
