#xml.instruct! :xml, :version => "1.0"

xml.assets do
  for asset in @assets
    xml.asset do
      xml.xid asset.xid
#      xml.id asset.id
      xml.locale @locale
      xml.link asset_url("#{asset.xid}_#{url_friendly(asset.title(@locale))}")#,:format=>"pdf") #"temp-link-for-now" #asset_url(@asset)
      xml.title asset.title(@locale)
      xml.short_title asset.short_title(@locale)
      xml.abstract asset.abstract(@locale)
      xml.da_type asset.da_type
      xml.da_subtype asset.da_subtype
      xml.published_at asset.published_at, "timestamp" => asset.published_at.to_i
      xml.expire_at asset.expire_at, "timestamp" => asset.expire_at.to_i
      xml.access_level asset.access_level
#      xml.tags asset.tag_names
    end
  end
end
