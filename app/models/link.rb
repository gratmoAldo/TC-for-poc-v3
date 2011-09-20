class Link < ActiveRecord::Base
  attr_accessible :asset_id, :url, :locale, :format

  belongs_to :asset

end
