class Note < ActiveRecord::Base

  attr_accessible :visibility, :effort_minutes, :note_type, :body, :created_by, :service_request_id

  VALID_SYSTEM_NOTE_TYPES = ["Administrative","Problem Description","Live chat","Notification Sent","Web Update","Mobile Update"]
  VALID_USER_NOTE_TYPES = ["Chat","Action Plan","Consult","Customer Contacted","Initial Response","L2 Consult","Research","Sent Email","Webex"]
  VISIBILITY_PUBLIC = "Public"
  VISIBILITY_INTERNAL = "Internal"
  VALID_VISIBILITY_VALUES = [VISIBILITY_INTERNAL, VISIBILITY_PUBLIC]  
  belongs_to :service_request
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by'
  validates_inclusion_of :note_type, 
                          :in => VALID_SYSTEM_NOTE_TYPES|VALID_USER_NOTE_TYPES,
                          :allow_nil => false,
                          :message => "must be valid note type"

  validates_presence_of   :service_request_id,
                          :allow_nil => false,
                          :message => "must be valid"
  validates_inclusion_of :visibility, 
                          :in => VALID_VISIBILITY_VALUES,
                          :allow_nil => false,
                          :message => "must be #{VALID_VISIBILITY_VALUES.join(' or ')}"

  before_save :sanatize                        

  named_scope :recent, lambda { |sr, role|
    if role == User::ROLE_EMPLOYEE
      # {:conditions => {"notes.service_request_id" => sr}, :order => "notes.updated_at DESC", :limit => 10}
      {:conditions => {"notes.service_request_id" => sr}, :order => "notes.updated_at DESC"}
    else
      # {:conditions => ["notes.service_request_id = ? and notes.visibility = ?",sr,VISIBILITY_PUBLIC], :order => "notes.updated_at DESC", :limit => 10}
      {:conditions => ["notes.service_request_id = ? and notes.visibility = ?",sr,VISIBILITY_PUBLIC], :order => "notes.updated_at DESC"}
    end
  }
  
  named_scope :with_fulltext, lambda { |keywords| # keywords is an array of keywords
    {:conditions => [Array.new(keywords.length){"(notes.body like ?)"}.join(" and ")] +
                     keywords.collect{|k| ["%#{k}%"]}
    } unless keywords.blank?
  }

  def sanatize
    self.body = self.body[0..4096] unless body.nil?
  end
  

  def valid_user_note_types
    VALID_USER_NOTE_TYPES
  end
  
  def clean_body
    # 'PROBLEM DESCRIPTION: ------------------------------------ When users in our Tokyo'
    body.gsub(/[ ]*PROBLEM DESCRIPTION[:\-\s]*|BUSINESS IMPACT[:\-\s]*|ENVIRONMENT INFORMATION[:\-\s]*|(\s)/i,' ').squeeze(' ').strip    
  end
  
  
end
