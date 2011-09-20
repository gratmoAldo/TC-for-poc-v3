class TopTag < ActiveRecord::Base
  attr_accessible :tag_id, :asset_id, :counter

  validates_uniqueness_of :asset_id, :scope => [:tag_id]

  belongs_to :asset
  belongs_to :tag

  named_scope :for_assets, lambda { |ids|
    {:conditions => {:asset_id => ids}}
  }
  named_scope :user_tags, { :include => :tag, :conditions => { :tags => {:namespace => nil}}}
  named_scope :machine_tags, { :include => :tag, :conditions => ['tags.namespace <> ?','']}

=begin  
Asset.all.each{|i| count=Tag.for_assets(i.id).approved.count('id', :group => 'tags.id');p count};nil

Tagging.count('tag_id', :group => 'taggings.tag_id')

#<OrderedHash {12=>3, 13=>2, 2=>1, 3=>1, 4=>1}>

a.top_tags

"[
#<TopTag id: 158, tag_id: 10, asset_id: 98, counter: 30, created_at: \"2010-06-29 23:43:59\", 
updated_at: \"2010-06-29 23:43:59\">, 
#<TopTag id: 159, tag_id: 17, asset_id: 98, counter: 4, created_at: \"2010-06-29 23:46:29\", 
updated_at: \"2010-06-29 23:46:29\">
]"

=end

BATCH_SIZE = 500

def self.refresh
  last_runtime = Admin._last_update


    # asset_list = Bookmark.updated_after(last_runtime).only_ids.limit(BATCH_SIZE).collect(&:asset_id)
    last_updated = Bookmark.updated_after(last_runtime).only_attributes(['updated_at']).least_recent.limit(BATCH_SIZE).map(&:updated_at).last
    # last_updated ||= Time.now
    # last_update = bookmark_list.last
    # logger.info "last_runtime=#{last_runtime}"
    # logger.info "last_update=#{last_update}"
    asset_list = Bookmark.updated_after(last_runtime).updated_before(last_updated).asset_ids.map(&:asset_id)
    # logger.info "asset_list (size=#{asset_list.size}) = #{asset_list.inspect}"
    # return
    
    return 0 if asset_list.blank?
    
    asset_list.each { |aid|
      l_toptags = Tag.for_assets(aid).approved.count('id', :group => 'tags.id')
      logger.info "Top tags for asset #{aid} = #{l_toptags.inspect}"
      TopTag.find_all_by_asset_id(aid).map(&:destroy)
      l_toptags.each do |tag| 
        TopTag.create! :tag_id => tag[0], :asset_id => aid, :counter => tag[1]  
      end


      # self.asset.top_tags.destroy_all
      # self.asset.top_tags = l_toptags.map{ |tag| TopTag.new :tag_id => tag[0], :asset_id => self.asset_id, :counter => tag[1]}
      # self.asset.save
    }
    Admin._last_update(last_updated)
    asset_list.size
end

end

