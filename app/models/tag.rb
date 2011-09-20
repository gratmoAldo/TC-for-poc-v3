class Tag < ActiveRecord::Base
  attr_accessible :display_name, :namespace, :key, :value, :name, :creator_id, :is_reviewed, :reviewer_id, :reviewed_at, :is_approved

  validates_presence_of :value, :name, :display_name, :creator_id

  has_many :taggings, :dependent => :destroy
  has_many :bookmarks, :through => :taggings
  has_many :assets, :through => :taggings
  has_many :top_tags

  named_scope :approved, {:conditions => {:is_approved => true}}
  named_scope :distinct, {:select => "DISTINCT tags.*"}
  named_scope :only_ids, {:select => "DISTINCT tags.id"}
  named_scope :with_namespace, lambda { |namespace| {:conditions => {"tags.namespace" => namespace}}}
  named_scope :with_key, lambda { |key| {:conditions => {"tags.key" => key}}}
  named_scope :user_tags, {:conditions => {"tags.namespace" => nil, "tags.key" => nil}}
  named_scope :machine_tags, {:conditions => ["tags.namespace <> ? or tags.key <> ?", '', '']}
  named_scope :for_assets, lambda { |ids|
    {:joins => :taggings, :conditions => {"taggings.asset_id" => ids}, :select => "DISTINCT tags.*"}
  }
  named_scope :for_user, lambda { |user_id| 
         conditions = {};
         conditions[:user_id] = user_id;
      { :joins => :bookmarks, :conditions => { :taggings => { :bookmarks => conditions}}}
      # {:conditions => { :taggings => { :tags => conditions}}}
  }


  def self.lookup(id)
    Tag.find :first, {:conditions => ["name=? or id=?",id.to_s.downcase,id]}    
  end

  def to_param
    display_name
  end

  def display_name=(val=nil)
    # puts "Setting display_name=#{val}"
    self[:display_name] = val # this syntax will avoid infinite loop!
    self.name = val.downcase
    if Tag.machine_tag? name
      tmp=name.gsub(/^(\w+):(\w+)=(.+)$/, '\1 \2 \3').split(" ")
      self.namespace = tmp.shift
      self.key = tmp.shift
      self.value = tmp.shift
    else
      self.value = name  
    end
  end
  # 
  # def self.tagganize(lname) # replaces '_' with space
  #   lname.gsub(/ /,'_')
  # end
  # 
  # def self.humanize(lname) # replaces '_' with space
  #   lname.gsub(/_/,' ')
  # end

  def self.machine_tag?(lname)
    lname =~ /^(\w+):(\w+)=(.+)$/
  end
  
  def machine_tag?
    !namespace.blank? || !key.blank?
  end
  
  def self.user_tag?(lname)
    lname =~ /^(\w+)$/
  end
  
  def user_tag?
    namespace.blank? && key.blank?
  end
  
  def self.get_machine_tag_from_name(lname)
    lname =~ /^(\w+):(\w+)=(.+)$/
    $1 ? {:namespace => $1, :key => $2, :value => $3} : nil
  end

  def self.find_or_create_by_name_with_creator(l_name, l_user )
    t = Tag.find_by_name(l_name.downcase)
    return t unless t.nil?
    if machine_tag?(l_name) or user_tag?(l_name)
    
      # Tag.create get_machine_tag_from_name(l_name).merge({:display_name => l_name, :creator_id => l_user})
    # elsif user_tag? l_name
      Tag.create :display_name => l_name, :creator_id => l_user
    else
      # return false
      raise "invalid tag: '#{l_name}'"
    end
  end

end
