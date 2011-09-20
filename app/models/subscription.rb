class Subscription < ActiveRecord::Base

  VALID_NOTIFICATION_METHODS = ["apn","c2dm"]  

  belongs_to :user
  belongs_to :service_request
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by'
  validates_uniqueness_of :display_id
  validates_uniqueness_of :token
  # , :token #, :token
  validates_inclusion_of :notification_method, 
                          :in => VALID_NOTIFICATION_METHODS,
                          :allow_nil => false,
                          :message => "must be valid notification method"

  
  before_save :set_token # should it be before_validate?
  
  named_scope :for_watchers, lambda { |ids| {:conditions => {"user_id" => ids}}}

# def validate_display_id
#   false
# end

  def device
    default_device = {:id=>nil}
    case notification_method.to_sym
    when :apn
      APN::Device.find(:first, :conditions => {"token" => self.display_id})||default_device
    when :c2dm 
      C2dm::Device.find(:first, :conditions => {"registration_id" => self.display_id})||default_device
    else
      default_device
    end
  end
  
  def token=(new_token) # does nothing
    logger.debug "should raise an exception here since token is system generated"
    new_token
  end
  
  private
  
  def set_token
    self.last_subscribed_at = Time.now
    return true unless self.token.nil? # TODO: could verify valid token format
    begin
      self[:token] = Digest::SHA1.hexdigest([self.last_subscribed_at, rand].join)
    end while Subscription.exists? :token => self.token # make sure it is unique
  end
  
end
