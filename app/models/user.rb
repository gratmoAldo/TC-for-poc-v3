class User < ActiveRecord::Base
  
  COMPANY_EMAIL_DOMAIN = 'cme.com'
  SYSTEM_USER = 'system'
  ROLE_EMPLOYEE = 1
  ROLE_PARTNER = 2
  ROLE_CUSTOMER = 3
  ROLE_FRIEND = 4
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :firstname, :lastname, :phone1, :locale, :password, :password_confirmation
  
  attr_accessor :password
  before_save :prepare_password
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  
  # named_scope :customers, {:conditions => {"users.is_deleted" => false}, :order => "users.firstname, users.lastname"}
  # named_scope :engineers, {:conditions => ["users.email like ? and users.username <> ?","%@#{COMPANY_EMAIL_DOMAIN}","system"]}
  named_scope :employees, {:conditions => ["users.role=#{ROLE_EMPLOYEE} and users.username <> ?",SYSTEM_USER]}
  named_scope :partners,  {:conditions => ["users.role=#{ROLE_PARTNER} and users.username <> ?",SYSTEM_USER]}
  named_scope :customers, {:conditions => ["users.role=#{ROLE_CUSTOMER} and users.username <> ?",SYSTEM_USER]}
  named_scope :friends,   {:conditions => ["users.role=#{ROLE_FRIEND} and users.username <> ?",SYSTEM_USER]}
  named_scope :active, {:conditions => {"users.is_deleted" => false}, :order => "users.firstname, users.lastname"}
  named_scope :active_admin, {:conditions => ["users.is_admin=? and users.is_deleted=?", true, false]}
  named_scope :active_normal, {:conditions => ["users.is_admin=? and users.is_deleted=?", false, false]}
  named_scope :only_ids, {:select => "DISTINCT users.id"}
  named_scope :limit, lambda { |limit| {:limit => limit} unless limit.nil? or limit < 1}
    
  has_many :bookmarks
  # has_many :inboxes, :foreign_key => :owner_id
  has_one :inbox, :foreign_key => :owner_id
  
  def self.watching_sr(sr_id)
    User.find_by_sql(
      "SELECT DISTINCT users.* FROM 'users' INNER JOIN inboxes i ON i.owner_id = users.id " \
      "INNER JOIN inbox_srs isr ON isr.inbox_id = i.id AND isr.service_request_id = #{sr_id.to_i}")
  end
  
  def fullname
    [firstname,lastname].join(' ')
  end
  
  def is_employee?
    role == ROLE_EMPLOYEE
  end
  
  def mark_as_deleted
    self.is_deleted = true
    save
  end
  
  def recover
    self.is_deleted = false
    save
  end

  # login can be either username or email address
  def self.authenticate(login, pass)
    sleep 1
    logger.info("--- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    logger.info("Authenticating with login=#{login} & pass=#{pass}")
    logger.info("---")
    user = active.find_by_username(login.downcase) || find_by_email(login)
    logger.info("Found user #{user.inspect}") if user
    return user if user && user.matching_password?(pass)
  end
  
  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end
