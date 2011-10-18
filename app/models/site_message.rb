class SiteMessage < ActiveRecord::Base

  attr_accessible :expires_at, :status, :message_function, :body, :created_by, :site_id, :created_at

  # getSiteRoles
  VALID_SITE_MESSAGE_FUNCTION_VALUES = ["CE", "Centera", "Clariion","CST","Dial Home","DSM", 
    "EDM","ESG CST","ESG Tech","IntlCST","MSS","NAS","Partner CE",
    "PREM","PSE","RxS", "SAM","SSC", "Triage","VCE","Web"]
  VALID_SITE_STATUS_VALUES = ["P","I"]
  belongs_to :site
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by'
  validates_inclusion_of :status, 
                          :in => VALID_SITE_STATUS_VALUES,
                          :allow_nil => false,
                          :message => "must be one of #{VALID_SITE_STATUS_VALUES.join(', ')}"

  validates_presence_of   :site_id,
                          :allow_nil => false,
                          :message => "must be valid"
  validates_inclusion_of :message_function, 
                          :in => VALID_SITE_MESSAGE_FUNCTION_VALUES,
                          :allow_nil => false,
                          :message => "must be ond of #{VALID_SITE_MESSAGE_FUNCTION_VALUES.join(', ')}"

  before_save :sanatize

  named_scope :recent, lambda { |site, role|
    if role == User::ROLE_EMPLOYEE
      # No limit for now, need paging
      if site.nil?
        {:order => "site_messages.created_at DESC"}
      else
        {:conditions => {"site_messages.site_id" => site}, :order => "site_messages.created_at DESC"}
      end
    else
      # Non-employees get no access to site messages
      {:conditions => ["1 = 0"]}
    end
  }
  
  named_scope :with_fulltext, lambda { |keywords| # keywords is an array of keywords
    {:conditions => [Array.new(keywords.length){"(site_messages.body like ?)"}.join(" and ")] +
                     keywords.collect{|k| ["%#{k}%"]}
    } unless keywords.blank?
  }

  def sanatize
    self.body = self.body[0..4096] unless body.nil?
  end
  

  def to_hash(options={})    
    options.reverse_merge! :locale => @locale
    {      
      :created_at => self.created_at.to_i,
      :expires_at => self.expires_at.to_i,
      :created_by_name => self.owner.fullname.to_s,
      :status => self.status.to_s,
      :message_function => self.message_function.to_s,
      :body => self.to_s      
    }
  end
end
