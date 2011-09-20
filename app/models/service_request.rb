class ServiceRequest < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'

  has_many :notes, :dependent => :destroy
  has_many :inbox_srs, :dependent => :destroy
  has_many :inboxes, 
           :through => :inbox_srs
  has_many :watchers, 
           :through => :inbox_srs,
           :source => :inbox,
           :select => "distinct inboxes.owner_id"

  belongs_to :site
  before_save :sanatize
  # belongs_to :escalation
  # after_save :notify_watchers
  
  named_scope :sort_by_sr_number, {:order => "service_requests.sr_number desc"}
  
  named_scope :with_fulltext, lambda { |keywords| # keywords is an array of keywords
    {:conditions => [Array.new(keywords.length){"(service_requests.title like ? or service_requests.description like ? or service_requests.product like ?)"}.join(" and ") +
                     " or service_requests.sr_number in (?)"] +
                     keywords.collect{|k| ["%#{k}%","%#{k}%","%#{k}%"]}.flatten +
                     [keywords]
    } unless keywords.blank?
  }
  
  
  def notes_count_per_role(role=User::ROLE_FRIEND)
    if role == User::ROLE_EMPLOYEE
      Note.count :conditions => ["notes.service_request_id = ?", self]
    else
      Note.count :conditions => ["notes.service_request_id = ? and notes.visibility = ?", self, Note::VISIBILITY_PUBLIC]
    end
  end

  def sanatize
    self.description = self.description[0..4096] unless description.nil?
  end


  def limited_description
    (description||"")[0..16384]
  end
  
  # def last_updated_at
  #   (self.notes.last || Note.new).created_at
  # end
      
  def to_param
    sr_number.to_s
  end

  def self.lookup(id)
    logger.info "Looking up SR #{id}"
    ServiceRequest.find :first, {:conditions => ["id=? or sr_number=?",id,id]}    
  end

  def last_updated_at
    last_note = self.notes.last
    return last_note.nil? ? self.updated_at : last_note.created_at
  end
  
  def last_updated_in_seconds
    return (Time.now - last_updated_at).to_i
  end

  
  def next_action_in_seconds
    return (Time.now - next_action_at).to_i
  end

  def severity_image
    "sr/S#{severity}"
  end  

  def severity_display
    "S#{severity}"
  end  
  
  def escalation_image
    return 's.gif' unless escalation > 0
    "sr/E#{escalation}"
  end  

  def escalation_display
    return nil unless escalation > 0
    "E#{escalation}" # TODO should look into related object instead of using the id
  end

  def queue(q)
    
  end

  def update_watcher
    logger.info("inside update_watcher")
#    users => their inboxes => inbox that don't include that sr
 
    # logger.info("inboxes for contact and owner = #{Inbox.owned_by([self.contact_id, self.owner_id]).inspect}")
    
    watchers = [self.owner_id, self.contact_id]
    a = Inbox.containing_sr_ids(self.id).only_ids.collect &:id
    b = Inbox.owned_by(watchers).collect &:id
    inbox_to_be_touched = b-a
    inbox_to_be_touched.each do |inbox_id|
      inbox = Inbox.find inbox_id
      logger.info "Adding SR ##{self.sr_number} to #{inbox.name}"
      inbox.service_requests << self
    end
#    find inboxes that do not include this service request amongst 
  end

  def clean_description
    # 'PROBLEM DESCRIPTION: ------------------------------------ When users in our Tokyo'
    description.gsub(/[ ]*PROBLEM DESCRIPTION[:\-\s]*|BUSINESS IMPACT[:\-\s]*|ENVIRONMENT INFORMATION[:\-\s]*|(\s)/i,' ').strip    
  end
  
  def worked_by(user)
     if user.class.name == "User"
       user_id = user.id 
     else
       user_id = user.to_i
     end
     [self.owner_id, self.contact_id].include? user_id
  end

=begin  
  def notify_watchers
    
    update_watcher
    logger.info("inside notify_owner")

    return if severity > 1
# TODO should look at all users who have the SR in their inbox
    logger.info "watchers = #{self.watchers.inspect}"

    # users = self.watchers
    subscriptions = Subscription.for_watchers(self.watchers.collect(&:owner_id))
    
    logger.info "subscriptions = #{subscriptions.inspect}"
    # find(:all, # TODO should handle multiple devices
    # :conditions => ["user_id=? and sr_severity>=?", self.watchers.collect(&:owner_id), severity])
    
    subscriptions.each do |subscription|
    # subscription = subscription.first
      if subscription
        devices = APN::Device.find(:all, :conditions => ["token=?", subscription.display_id])
        if devices.empty?
          app = APN::App.first ## TODO should look up be name
          if app
            devices = [APN::Device.create(:token => subscription.display_id,:app => app)]
          end
        end

        sound_filename ='startrek_new-note.caf'
        
        # logger.info "escalation=#{escalation}; sound_filename =  #{sound_filename}"
        # logger.info "devices are  #{devices.inspect}"

        unless devices.empty?
          devices.each do |device|
            # link = {:sr_number => sr_number}
            priority = severity_display
            message = "SR ##{sr_number} (#{priority}) was just updated"
            if escalation > 0
              sound_filename = 'startrek_escalation.caf'
              priority += " / #{escalation_display}"
              message = "SR ##{sr_number} just got escalated to #{priority}"
            end
            notification = {:device => device, 
              :badge=>subscription.badge,
              :sound=>sound_filename, 
              :alert=>message,
              :custom_properties => {:sr_number => sr_number}
            }
            logger.info "notify_owner with  #{notification.inspect}"
            APN::Notification.create notification
          end
        end
      end
    end
  end
=end
  
  #       iOS token =~ /^[0-9a-f\-]{71}$/
  #       Android token =~ /^[\-\_0-9a-z]{119}$/i
  
  # def create_ios_notification(payload={})
  #   
  # end
    
end
