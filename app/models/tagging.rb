class Tagging < ActiveRecord::Base
  # attr_accessible :tag_id, :user_id, :asset_id, :bookmark_id, :created_at
  attr_accessible :tag_id, :bookmark_id

  belongs_to :tag, :counter_cache => true
  belongs_to :asset
  belongs_to :bookmark

  before_save :fix_attributes
  
  def fix_attributes
    self.asset_id = bookmark.asset_id if bookmark_id
  end
  
end
