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
    (description.to_s)[0..16384]
  end
  
  # def last_updated_at
  #   (self.notes.last || Note.new).created_at
  # end
      
  def to_param
    sr_number.to_s
  end

  def self.lookup(id)
    # logger.info "Looking up SR #{id}"
    ServiceRequest.find :first, {:conditions => ["id=? or sr_number=?",id,id]}    
  end

  def last_updated_at
    last_note = self.notes.last
    # logger.info "last updated at - last_note = #{last_note.inspect}"
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

  def filtered_description
    # 'PROBLEM DESCRIPTION: ------------------------------------ When users in our Tokyo'
    description.gsub(/[ ]*PROBLEM DESCRIPTION[:\-\s]*/i,' ').strip    
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

  def to_hash(options={})    
    options.reverse_merge! :role => User::ROLE_FRIEND, :user_id => 0, :format => :summary
    
    # logger.info "user role is #{options[:role]}"
    res = {
      :sr_number => self.sr_number.to_i,
      :sr_status => self.status.to_s,
      :title => self.title.to_s,
      :severity => self.severity.to_i,
      :escalation => self.escalation.to_i,
      :product => self.product.to_s,
      :site_name => self.site.name.to_s,
      :nb_notes => self.notes_count_per_role(options[:role]),
      
      :next_action_at => self.next_action_at.to_i,
      :last_updated_at => self.last_updated_at.to_i,
      :created_at => self.created_at.to_i,
      :closed_at => self.closed_at.to_i,
      
      :is_customer => self.contact_id == options[:user_id],
      :is_agent => self.owner_id == options[:user_id]
    }

      # Deprecated
      # :last_updated_in_words => how_old((Time.now - self.last_updated_at).to_i, :format => :long, :ago => true), #{}"#{1+rand(12)} hours ago",
      # :next_action_in_words => how_old((Time.now - self.next_action_at).to_i, :format => :long, :ago => true),
      # :customer => self.site.name, # renamed to site_name
    if options[:format] == :complete
      res.merge! :problem_description => self.filtered_description,
          :site_address => self.site.address.to_s,
          :site_id => self.site.site_id.to_i,
          :customer_name => self.contact.fullname.to_s,
          :customer_email => self.contact.email.to_s,
          :customer_phone1 => self.contact.phone1.to_s,
          :customer_phone2 => self.contact.phone2.to_s,
          :agent_name => self.owner.fullname.to_s,
          :agent_email => self.owner.email.to_s,
          :agent_phone1 => self.owner.phone1.to_s,
          :agent_phone2 => self.owner.phone2.to_s,
          :recent_notes => @notes.collect(&:to_hash)
          
      end
      # logger.info "ServiceRequest to hash returnin #{res.inspect}"
      res
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
