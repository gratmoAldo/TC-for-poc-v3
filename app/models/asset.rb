class Asset < ActiveRecord::Base

  attr_accessible :sid, :source, :xid, :da_type, :da_subtype, :entitlement_model, :entitlement_value
  attr_accessible :popularity, :avg_rating, :published_at, :expire_at, :is_deleted, :translations_attributes, :links_attributes

  # DEFAULT_LOCALE = "en_US"
  # ASSET_TYPES = %w(Documentation Solution)
  ACCESS_LEVEL_MODEL = 1
  ACCESS_LEVELS = [10,20,30,40,50]
  POPULARITY_RANGE = 1..100
  validates_uniqueness_of :sid, :scope => [:source]

  # validates_inclusion_of :atype, :in => ASSET_TYPES, :message => "value is invalid"
  validates_presence_of :sid, :xid, :source, :da_type, :da_subtype, :expire_at, :published_at
  # validates_inclusion_of :access_level, :in => ACCESS_LEVELS, :message => "value must be #{ACCESS_LEVELS.join(',')}"
  validates_inclusion_of :popularity, 
                         :in => POPULARITY_RANGE,
                         :message => "must be between 1 and 100"
  # validates_inclusion_of :locale, :in => $locales

  has_many :taggings
  has_many :tags, :through => :taggings, :order => "tags.value"
  has_many :translations, :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy
  has_many :links, :dependent => :destroy
  has_many :top_tags, :order => "top_tags.counter desc"

  accepts_nested_attributes_for :translations, :links

  # attr_accessor :locale
  # attr_writer :tag_names
  # before_save :set_all_tags
  # after_save :post_save_actions
  # after_update :save_translations

  # named_scope :active, {:conditions => {"assets.is_deleted" => true}}
  # named_scope :most_popular, {:order => "assets.popularity DESC, assets.published_at DESC, translations.title DESC"}
  named_scope :most_recent, {:order => "assets.published_at DESC, translations.title DESC"}
  named_scope :sort_by_xid, {:order => "assets.xid DESC"}
  named_scope :sort_by_popularity, {:order => "assets.popularity DESC"}
  # named_scope :order_by, lambda { |order,dir|
  #   case order
  #   when "date"
  #     {:order => "assets.published_at #{dir}, translations.title #{dir}"}
  #   when "title"      
  #     {:order => "translations.title #{dir}"}
  #   end
  #   }

  # named_scope :alphabetical, {:include => :translations, :order => "translations.title DESC"}
  named_scope :distinct, {:select => "DISTINCT assets.*"}
  named_scope :only_ids, {:select => "DISTINCT assets.id"}
  named_scope :with_ids, lambda { |ids| {:conditions => {"assets.id" => ids}}}
  named_scope :with_access, lambda { |access| {:conditions => ["assets.entitlement_model = ? and assets.entitlement_value <= ?", ACCESS_LEVEL_MODEL, access]}}
  named_scope :with_locale, lambda { |locale| { :include => :translations, :conditions => { :translations => {:locale => locale}}}}
  # named_scope :get_asubtypes, {:select => "distinct(assets.asubtype)"}
  named_scope :limit, lambda { |limit| {:limit => limit} unless limit.nil? or limit < 1}
  # named_scope :with_ids, lambda { |ids| {:conditions => {"assets.id" => ids}}}
  named_scope :with_type, lambda { |datype| {:conditions => {"assets.da_type" => datype}} unless datype.blank?}
  named_scope :with_subtype, lambda { |dasubtype| {:conditions => {"assets.da_subtype" => dasubtype}} unless dasubtype.blank?}
  # named_scope :with_any_subtype, lambda { |subtypes| {:conditions => [Array.new(subtypes.length){"assets.asubtype = ?"}.join(" or ")] + subtypes}}

  named_scope :tagged_with_all, lambda { |tags|
    joins = []
    
    tags.to_s.downcase.split(" ").each_with_index do |tag, index|
      taggings_alias, tags_alias = "taggings_all_#{index}", "tags_all_#{index}"
      join = "INNER JOIN taggings #{taggings_alias} ON #{taggings_alias}.asset_id = assets.id \
        INNER JOIN tags #{tags_alias} ON #{taggings_alias}.tag_id = #{tags_alias}.id AND #{tags_alias}.name = ? AND #{tags_alias}.is_approved = ?"
      joins << sanitize_sql([join, tag, true])
    end
    { :joins => joins.join(' ') } unless tags.blank?
  }
  
  named_scope :tagged_with_any, lambda { |tags|
    # { :joins => :tags, :as => 'tag1', :conditions => { :taggings => { :tags => {:name => tags.downcase.split(' '), :is_approved => true}}}} unless tags.blank?
    @index||=0
    @index+=1
    taggings_alias, tags_alias = "taggings_any_#{@index}", "tags_any_#{@index}"
    # join = "INNER JOIN taggings tag1 ON (assets.id = taggings.asset_id") INNER JOIN "tags" ON ("tags"."id" = "taggings"."tag_id") WHERE ("tags"."is_approved" = 't' AND "tags"."name" IN ('installation')) 
    
    joins = []
    
      # taggings_alias, tags_alias = "taggings_#{index}", "tags_#{index}"
      join = "INNER JOIN taggings #{taggings_alias} ON #{taggings_alias}.asset_id = assets.id \
        INNER JOIN tags #{tags_alias} ON #{taggings_alias}.tag_id = #{tags_alias}.id AND (#{tags_alias}.name IN (?) AND #{tags_alias}.is_approved = ?)"
      joins << sanitize_sql([join, tags.to_s.split(' '), true])
    { :joins => joins.join(' ') } unless tags.blank?
  }
      
  named_scope :with_fulltext, lambda { |keywords| # keywords is an array of keywords
    {:conditions => [Array.new(keywords.length){"(translations.title like ? or translations.abstract like ?)"}.join(" and ") +
                     " or xid in (?)"] +
                     keywords.collect{|k| ["%#{k}%","%#{k}%"]}.flatten +
                     [keywords]
    } unless keywords.blank?
  }

  named_scope :order_by, lambda { |order,dir|
    case order
    when "date"
      {:order => "assets.published_at #{dir}, translations.title #{dir}"}
    when "title"      
      {:order => "translations.title #{dir}"}
    end
    #    "assets.#{order} #{dir}"}
  }

  def to_param
    ltitle = title('en_US')||''
    # TODO encoding to support double-byte UTF-8 encoding
    "#{xid}_#{ltitle.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-')}".slice(0,100)
  end

  def self.extract_id(uri)
    (/([a-z][a-z|-]+[0-9]{1,12})/i.match uri).to_s
  end

  def self.lookup(id)
    Asset.find :first, {:conditions => ["id=? or xid=?",id,Asset.extract_id(id)]}    
  end

  # def self.custom_find(params={}, user=nil)
  #   # logger.info "Inside Asset.custom_find(options=#{params.inspect}, user=#{user.inspect})"
  #   scope = Asset.scoped({})
  #   scope = scope.scoped :conditions => {'assets.sid' => params[:i].split(',')} if params[:i]
  #   scope = scope.scoped :include => "translations"
  #   scope
  # end

  def translation_for(locale_arg)
    @translations_for ||= {}
    @translations_for[locale_arg] ||= translations.find_by_locale(locale_arg)||translations.build
    # @translations_for[locale_arg] ||= false #:no_translation
  end

  def self.find_and_update_or_create_by_sid(asset_attributes)
    # logger.info "asset_attributes=#{asset_attributes.inspect}"
    existing_asset = Asset.find_by_sid(asset_attributes[:sid])
    if existing_asset
      if existing_asset.xid == asset_attributes[:xid]
        existing_asset.update_attributes_from!(asset_attributes, :exclude => ['sid', 'xid', 'id', 'created_at', 'updated_at'])
      else
        logger.error "xid mismatch for sid #{existing_asset.sid}"
        nil
      end
    else
      Asset.create(asset_attributes)
    end
  end
  
  def mark_as_deleted
    self.is_deleted = true
    save
  end
  
  def recover
    self.is_deleted = false
    save
  end

  def access_level
    entitlement_model == ACCESS_LEVEL_MODEL ? entitlement_value : 0
  end
  
  def update_attributes_from!(attributes, options={})
    options.reverse_merge! :exclude => [] #, :non_nil => ['sid']

    # logger.info "update_attributes_from!: attributes=#{attributes.inspect} and options=#{options.inspect} and self=#{self.inspect}"

    exclude = options[:exclude]
    # non_nil = options[:non_nil]

    self.attribute_names.each {|attr|
      # logger.info "attr before=#{attr}"
      # attr=nil if attr.empty? and non_nil.include? attr
      # logger.info "attr after=#{attr}"
      unless exclude.include? attr
        # logger.info "* updating self[#{attr}]=\"#{self.attributes[attr]}\" vs attributes=\"#{attributes[attr.to_sym]}\""
        self.attributes = { attr => attributes[attr.to_sym] } 
      else
        # logger.info "- skipping self[#{attr}]=\"#{self.attributes[attr]}\" vs attributes=\"#{attributes[attr.to_sym]}\""
      end
      } if attributes
      # logger.info "new self before save=#{self.inspect}"
      self
    end

=begin
    def new_translation_attributes=(translation_attributes)
         logger.info "new_name_attributes= with #{name_attributes.inspect}"
      translation_attributes.each do |attributes|
        logger.info "translation_attributes.each with translation=#{attributes.inspect}"

        # TODO forcing active for new names until problem with checkbox resolved in html form
        # attributes[:is_active] = true

        translations.build(attributes) unless attributes[:title].empty?
      end
    end


    def existing_translation_attributes=(translation_attributes)
         logger.info "existing_name_attributes= with #{name_attributes.inspect}"
      translations.reject(&:new_record?).each do |translation|
        #      logger.info "names.reject with name=#{name.inspect}"
        attributes = translation_attributes[translation.id.to_s]
        if attributes
          translation.attributes = attributes
        else
          logger.info "Not found! deleting"
          translations.delete(translation)
        end
      end
    end
=end    

    def locales
      @locales ||= Translation.find_all_by_asset_id(id,{:select => "locale"}).collect(&:locale)
    end


    # create new methods to access translated attributes
    translation_attributes = Translation.new.attribute_names - ["asset_id", "locale", "created_at", "updated_at"]
    translation_attributes.each do |translation_attribute|
      define_method translation_attribute do |*llocale|
        locale = *llocale.first || 'en_US'
        translation_for(locale).send translation_attribute if translation_for(locale)
      end
    end
end


=begin
  queries
  - find all assets tagged by product key (A or B or C) and also tagged with X
  - given a list of asset IDs, find top 50 tags by occurence
  - given a list of asset IDs, find all tags by namespace and key
  - given an asset, find most popular tags (tag used by at least 2 people)
  - get system tags for an asset
  - get my tags for an asset
  - get all my tags across my bookmarks
  - get all my bookmarks
  - get all bookmarks for an asset and sort by date
  - find a tag from all my tags matching a fragment
  - find most recent 20 assets to have been tagged
  - given a product id, what are the most popular tags, ever
  - given a product id, what are the most popular tags, in the last 3 months, last week?
  - given a product id, what are the top tagged assets, ever
  - given a product id, what are the top tagged assets, in the last 3 months, last week?
  - given an asset id, who tagged it?
  




--- Show all assets tagged with any of the products from a cluster + tagged with a machine tag

  URL friendly name = "ContentServer"
  
  PID = 1091
  
  Cluster for 1091 = 1091, 1066, 1081
  
  find all assets 
    - tagged with "tuning"
    - tagged with ""
  
  
  find all assets 
    - tagged with pid (product:pid=1091 or product:pid=1066 or product:pid=1081) 
    - and tagged with (documentation:task=troubleshoot)


from Taggings where tag_id in (select id from tag where name in ('product:pid=1194', 'product:pid=1200')) 



--- Show user's bookmarks
from Bookmarks where user_id='16'

--- Show user's tags
Tag.user_by(16)

:joins


=end
  
  
  
  
=begin
INNER JOIN taggings assets_taggings ON assets_taggings.asset_id = assets.id 
INNER JOIN tags assets_tags ON assets_tags.id = assets_taggings.tag_id 

Asset.find(:all, :select => "DISTINCT assets.*", :joins => "
INNER JOIN taggings taggings_0 ON taggings_0.asset_id = assets.id INNER JOIN tags tags_0 ON taggings_0.tag_id = tags_0.id AND tags_0.name = 'product:pid=1194' 
INNER JOIN taggings taggings_1 ON taggings_1.asset_id = assets.id INNER JOIN tags tags_1 ON taggings_1.tag_id = tags_1.id AND tags_1.name = 'aix'
")

  :conditions => conditions.join(" AND ")
}



  Asset.find_by_sql(
  "SELECT DISTINCT assets.* FROM 'assets'
  
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


  # asset={:popularity=>59, :xid=>"doc40000", :da_type=>"Documentation", :sid=>"doc40000", 
  #   :published_at=>Sun, 01 Oct 2006, :da_subtype=>"Manual and Guides", :source=>"publisher", 
  #   :expire_at=>Sat, 01 Oct 2016, :entitlement_model=>1, :is_deleted=>false, :entitlement_value=>10}
