class Translation < ActiveRecord::Base
  attr_accessible :asset_id, :locale, :title, :short_title, :abstract, :thumbnail_s, :thumbnail_m, :thumbnail_l

  validates_uniqueness_of :asset_id, :scope => [:locale]
  
  belongs_to :asset

end
