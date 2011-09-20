#xml.instruct! :xml, :version => "1.0"
xml.documentation do

  xml.assets do
    for asset in @assets
      xml.asset do
        xml.xid asset.xid
  #      xml.id asset.id
        xml.locale @locale
        xml.title asset.title(@locale)
        xml.abstract asset.abstract(@locale)
        xml.htitle highlight(asset.title(@locale),@keywords)
        xml.habstract highlight(asset.abstract(@locale),@keywords)
        xml.hxid highlight(asset.xid,@keywords)
        xml.short_title asset.short_title(@locale)
        xml.da_type asset.da_type
        xml.da_subtype asset.da_subtype
        xml.published_at asset.published_at, "timestamp" => asset.published_at.to_i
        xml.expire_at asset.expire_at, "timestamp" => asset.expire_at.to_i
        xml.entitlement_model asset.entitlement_model
        xml.entitlement_value asset.entitlement_value
        xml.link asset_url("#{asset.xid}_#{url_friendly(asset.title(@locale))}")#,:format=>"pdf") #"temp-link-for-now" #asset_url(@asset)
  #      xml.tags asset.tag_names
      end
    end
  end

  xml.meta do
    xml.product_name @product_name
    xml.page @page
    xml.per_page @per_page, :default => DocumentationsController::DEFAULTS[:per_page]
    xml.order @order, :default => DocumentationsController::DEFAULTS[:order]
    xml.total_entries @total_entries
    xml.locale @locale
  end  

  xml.filters do
    xml.product @products.join(',') unless @products.empty?
    xml.subtype @subtypes.map{|s| url_friendly s}.join(',') unless @subtypes.empty?
    xml.task @tasks.map{|t| url_friendly t}.join(',')       unless @tasks.empty?
    xml.search @keywords.join(' ')  unless @keywords.empty?
  end  
  
  xml.f_products do
    for product in @f_products
      xml.product do
        xml.dname product[:dname]
        xml.uname product[:uname]
        # xml.fname DocumentationsController::LONG_PRODUCT_MAPPING[product]
        xml.count product[:count]
      end
    end
  end
  
  xml.f_subtypes do
    for subtype in @f_subtypes
      xml.subtype do
        xml.dname subtype[:dname]
        xml.uname subtype[:uname]
        xml.count subtype[:count]
      end
    end
  end
  
  xml.f_tasks do
    for task in @f_tasks
      xml.task do
        xml.dname task[:dname]
        xml.uname task[:uname]
        xml.count task[:count]
      end
    end
  end  
end