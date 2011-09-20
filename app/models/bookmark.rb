class Bookmark < ActiveRecord::Base
  
  attr_accessible :user_id, :asset_id, :title, :note, :is_private, :is_system
  
  validates_uniqueness_of :asset_id, :scope => [:user_id], :message => "has already been bookmarked"
  validates_presence_of :title, :message => "can't be blank"
  validates_presence_of :user_id, :message => "can't be blank"
  validates_presence_of :asset_id, :message => "can't be blank"
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings, :order => "tags.value"
  belongs_to :asset, :counter_cache => true
  belongs_to :user
  
  attr_accessible :all_tags
  validates_presence_of :all_tags, :message => "can't be blank"
  attr_writer :all_tags
  before_save :process_all_tags
  # after_save :update_top_tags
  
  named_scope :recently_created, {:order => "bookmarks.created_at DESC"}
  named_scope :least_recent, {:order => "bookmarks.updated_at"}
  named_scope :asset_ids, {:select => "DISTINCT bookmarks.asset_id"}
  named_scope :only_ids, {:select => "DISTINCT bookmarks.id"}
  named_scope :only_attributes, lambda { |selection| {:select => selection.join(',')}}
  named_scope :updated_after, lambda { |timestamp| {:conditions => ["bookmarks.updated_at > ?",timestamp||10.years.ago]}}
  named_scope :updated_before, lambda { |timestamp| {:conditions => ["bookmarks.updated_at <= ?",timestamp||Time.now]}}
  named_scope :limit, lambda { |limit| {:limit => limit} unless limit.nil? or limit < 1}
  named_scope :for_user, lambda { |user_id| {:conditions => ["bookmarks.user_id = ?",user_id]}}
  named_scope :for_assets, lambda { |asset_ids| {:conditions => ["bookmarks.asset_id in (?)",asset_ids]}}
  
  # updated_after(last_runtime).asset_ids

  # This method finds bookmarks, possibly ones tagged with a
  # particular tag.
  def self.custom_find(user=nil, tag=nil, limit=nil)
    conditions = ["user_id=?",user]
    if tag       
      # When a tag restriction is specified, we have to find bookmarks
      # the hard way: by constructing a SQL query that matches only
      # bookmarks tagged with the right tag.
      sql = ["SELECT DISTINCT bookmarks.* FROM bookmarks, tags, taggings" +
             " WHERE " +
             " bookmarks.id = taggings.bookmark_id" +
             " AND taggings.tag_id = tags.id AND tags.name in (?)",
             tag.downcase.split(' ')]
      if conditions
        sql[0] << " AND " << conditions[0]
        sql += conditions[1..conditions.size]
      end
      sql[0] << " ORDER BY bookmarks.created_at DESC"
      sql[0] << " LIMIT " << limit.to_i.to_s if limit
      bookmarks = find_by_sql(sql)
    else
      # Without a tag restriction, we can find bookmarks the easy way:
      # with the superclass find() implementation.
      bookmarks = find(:all, {:conditions => conditions, :limit => limit,
                              :order => 'created_at DESC'})
    end    
    return bookmarks
  end
=begin
  Asset.find_by_sql(
  "SELECT DISTINCT assets.* FROM 'assets'
  
   INNER JOIN taggings assets_taggings ON assets_taggings.asset_id = assets.id 
    
   INNER JOIN tags assets_tags ON 
   assets_tags.id = assets_taggings.tag_id 

   INNER JOIN taggings taggings_0 ON
   taggings_0.asset_id = assets.id 
   
   INNER JOIN tags tags_0 ON
   taggings_0.tag_id = tags_0.id AND
   tags_0.name = 'product:pid=1194'

   INNER JOIN taggings taggings_1 ON
   taggings_1.asset_id = assets.id
   
   INNER JOIN tags tags_1 ON
   taggings_1.tag_id = tags_1.id AND
   tags_1.name = 'aix'"  )
=end

=begin
  Note.find_by_sql(
  "SELECT DISTINCT notes.* FROM 'notes'
  
   INNER JOIN taggings notes_taggings ON notes_taggings.taggable_id = notes.id 
   AND notes_taggings.taggable_type = 'Note' 
    
   INNER JOIN tags notes_tags ON 
   notes_tags.id = notes_taggings.tag_id 

   INNER JOIN taggings taggings_0 ON
   taggings_0.taggable_id = notes.id AND
   taggings_0.taggable_type = 'Note'

   INNER JOIN tags tags_0 ON
   taggings_0.tag_id = tags_0.id AND
   tags_0.name = 'a'

   INNER JOIN taggings taggings_1 ON
   taggings_1.taggable_id = notes.id AND
   taggings_1.taggable_type = 'Note'

   INNER JOIN tags tags_1 ON
   taggings_1.tag_id = tags_1.id AND
   tags_1.name = 'b'"  )
=end





  def all_tags
    @all_tags || tags.map(&:name).join(' ')
  end

  def process_all_tags
    l_all_tags = @tall_tags || self.all_tags

    if l_all_tags
      self.tags = l_all_tags.split(" ").map do |one_tag|
        Tag.find_or_create_by_name_with_creator(one_tag, user_id)
      end      
    end

    # Ensure that machine tag are not used other than with a system bookmark
    @uses_machine_tag = false
    unless self.is_system
      self.tags.each do |tag|
        logger.info "#{tag.display_name} is a machine tag!" if tag.machine_tag?
        @uses_machine_tag = true if tag.machine_tag?
      end
      if @uses_machine_tag
        errors.add(:all_tags, "contains an invalid tag")
        return false
      end
    end
  end
  
  def update_top_tags        
    l_toptags = Tag.for_assets(self.asset.id).approved.count('id', :group => 'tags.id')
    logger.info "Top tags for asset #{asset.id} = #{l_toptags.inspect}"
    self.asset.top_tags.destroy_all
    self.asset.top_tags = l_toptags.map{ |tag| TopTag.new :tag_id => tag[0], :asset_id => self.asset_id, :counter => tag[1]}
    self.asset.save
  end
  
# select * from bookmarks where id in (select id from bookmarks b1 where b1.updated_date < 25.minutes.ago order by updated_date desc limit 100) order by updated_at limit 1
  
  
end
