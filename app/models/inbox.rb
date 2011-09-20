class Inbox < ActiveRecord::Base

  has_many :inbox_srs, :dependent => :destroy
  has_many :service_requests, 
           :through => :inbox_srs,
           :order => "service_requests.sr_number desc"

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'

  named_scope :distinct, {:select => "DISTINCT inboxes.*"}
  named_scope :only_ids, {:select => "DISTINCT inboxes.id"}
  named_scope :owned_by, lambda { |ids| {:conditions => {"inboxes.owner_id" => ids}}}
  named_scope :containing_sr_ids, lambda { |ids| { :include => :inbox_srs, :conditions => { :inbox_srs => {"inbox_srs.service_request_id" => ids}}}}
  named_scope :active, {:include => :owner, :conditions => ["users.is_admin=? and users.is_deleted=?", false, false], :order => "inboxes.name"}
  # def to_json(noarg=nil)
    # {:name => name, :owner_name => owner.fullname, :owner_id => owner.id}.to_json
  # end

end
