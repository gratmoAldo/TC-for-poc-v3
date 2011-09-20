class DocumentationsController < ApplicationController

  before_filter :login_optional
  # before_filter :login_required

    PID_FOR_TEST = 1194
    ALL_PIDS_FOR_TEST = [1194, 1195, 1196, 1197, 1198, 1199, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207,1208, 1209, 1211, 1293]

    DEFAULTS = {:per_page => 10, :order => "date"}

    LONG_PRODUCT_MAPPING = {
      1194 => "Nayworker", 
      1195 => "Nayworker Dashboard Option",
      1196 => "Nayworker DiskBackup Option",
      1197 => "Nayworker Dynamic Drive Sharing Option",
      1198 => "Nayworker Management Console Option",
      1199 => "Nayworker Module for Centera",
      1200 => "Nayworker Module for Documen",
      1201 => "Nayworker Module for IBM DB2",
      1202 => "Nayworker Module for IBM Informix",
      1203 => "Nayworker Module for IBM Lotus Notes/Domino",
      1204 => "Nayworker Module for MEDITECH",
      1205 => "Nayworker Module for Microsoft Exchange",
      1206 => "Nayworker Module for Microsoft SQL Server",
      1207 => "Nayworker Module for Oracle",
      1208 => "Nayworker Module for PowerSnap",
      1209 => "Nayworker Module for SAP R/3 on Oracle",
      1211 => "Nayworker Module for Sybase",
      1293 => "Nayworker Module for Microsoft Applications"
      }

      PRODUCT_MAPPING = {
        1194 => "Nayworker", 
        1195 => "Nayworker Dashboard Option",
        1196 => "Nayworker DiskBackup Option",
        1197 => "NW Dynamic Drive Sharing Option",
        1198 => "Management Console Option",
        1199 => "Module for Centera",
        1200 => "Module for Documen",
        1201 => "Module for IBM DB2",
        1202 => "Module for IBM Informix",
        1203 => "Module for Notes/Domino",
        1204 => "Module for MEDITECH",
        1205 => "Module for MS Exchange",
        1206 => "Module for MS SQL Server",
        1207 => "Module for Oracle",
        1208 => "Module for PowerSnap",
        1209 => "Module for SAP R/3 on Oracle",
        1211 => "Module for Sybase",
        1293 => "Module for MS Applications"
        }
      
    TASKS = %w( General Plan Install Configure Administer Using Maintain Customize Optimize Troubleshoot )
    DOC_SUBTYPES = ["Manual and Guides", "Getting Started", "Reference", "Release Notes", "Technical Note", "Tool"]
    ORDER_BY_VALUES = ["date", "title"]

    # TMP expiration function
    def expire_cache
      pid = PID_FOR_TEST
          doc_pid_key = "doc_#{pid}"
          prod_pid_key = "prod_#{pid}"
      Rails.cache.delete(doc_pid_key)
      Rails.cache.delete(prod_pid_key)
      flash[:notice] = "Successfully expired all caches"
      redirect_to root_url
    end


    # Returns a list of documentations for a given product name
    def show
      @assets = nil
      # @locale = current_locale params[:l]

      # access_level = params[:a]||10
      @page = [(params[:page]||1).to_i, 1].max      
      @per_page = [[(params[:per_page]||DEFAULTS[:per_page]).to_i, 3].max, 100].min
      @tasks = (params[:task]||'').split(',')
      @subtypes = (params[:subtype]||'').split(',')
      @order = ([params[:order]] & ORDER_BY_VALUES).first||DEFAULTS[:order]
      @products = (params[:product]||'').split(',')
      @keywords = (params[:search]||'').split(' ')

      product_mapping_by_uname = ""
      doc_pid_key = ""
      prod_pid_key = ""
      pid_tag_list = ""
      pid=""
      all_pids=""
      pname=""
      task_tag_list=""
      tmp_tags=
      products=""
      tags=""
      tmp_subtypes=""
      subtypes=""
      tasks=[]
      supported_tasks=[]

      logger.info "@locale=#{@locale}; @access_level=#{@access_level}"
ben = []
ben << ["REF001", Benchmark.ms {

      doc_subtype_mapping = {}
      DOC_SUBTYPES.each_with_index do |subtype,i|
        doc_subtype_mapping[url_friendly(DOC_SUBTYPES[i])] = DOC_SUBTYPES[i]
      end      
      @subtypes.each { |subtype| subtype.replace doc_subtype_mapping[subtype] unless doc_subtype_mapping[subtype].nil? }

      }.to_s]

      ben << ["REF002", Benchmark.ms {
      
      # logger.info "doc_subtype_mapping=#{doc_subtype_mapping.inspect}"
      # logger.info "@subtypes=#{@subtypes.inspect}"
      # logger.info "subtype_from_uname=#{subtype_from_uname}"

      # logger.info "@tasks = #{@tasks.inspect}, @subtypes = #{@subtypes.inspect}"

      # TODO - These value should be served by Product Master translating pname into 
      # pids=[1194, 1207].sort # Hard-coded Nayworker + Module for Oracle PID
      pname = params[:pname]
      pid = PID_FOR_TEST
      all_pids = ALL_PIDS_FOR_TEST


      doc_pid_key = "doc_#{pid}"
      prod_pid_key = "prod_#{pid}"

      # Retrieve list of asset ids for large query or build the cache
      pid_tag_list = all_pids.map{|p| "product:pid=#{p}"}.join(" ")



      # Rails.cache.delete(doc_pid_key)
      # Rails.cache.delete(prod_pid_key)


      }.to_s]

      asset_ids = []
      ben << ["REF003", Benchmark.ms {

      asset_ids = Rails.cache.fetch(doc_pid_key) { Asset.only_ids.with_type("Documentation").tagged_with_any(pid_tag_list).with_locale(@locale).with_access(50).most_recent.limit(500).map(&:id) }
      logger.info "asset_ids=#{asset_ids.inspect}"


      
      }.to_s]
      ben << ["REF004", Benchmark.ms {
      
      
      
      
      
      product_mapping_by_uname = Rails.cache.fetch(prod_pid_key) do
        unames = {}
        DocumentationsController::PRODUCT_MAPPING.each do |product|
          unames[url_friendly(product[1])] = product[0]
          # logger.info "product = #{product} -> uname = #{unames[url_friendly(product[1])]}"
        end
        unames
      end
      
      
      }.to_s]
      ben << ["REF005", Benchmark.ms {
      
      # logger.info "product_mapping_by_uname=#{product_mapping_by_uname.inspect}"
      # logger.info "@product(before)=#{@products.inspect}"

      @product_keys = @products.map{|p| product_mapping_by_uname[p]}.compact

      }.to_s]
      ben << ["REF006", Benchmark.ms {
      # logger.info "@product(after)=#{@product_keys.inspect}"

      if @products.empty? || (!@products.empty? && !@product_keys.empty?)

        # Get list of assets applying filters & pagination
        pid_tag_list = @product_keys.map{|p| "product:pid=#{p}"}.join(" ")
        task_tag_list = @tasks.map{|p| "documentation:task=#{p}"}.join(" ")
        # logger.info "pid_tag_list=#{pid_tag_list.inspect}"
        # logger.info "task_tag_list=#{task_tag_list.inspect}"
        
        # @assets = Asset.with_ids(asset_ids).tagged_with_any(pid_tag_list).tagged_with_any(task_tag_list).with_subtype(@subtypes).with_locale(@locale).with_fulltext(@keywords).with_access(access_level).order_by(@order,"desc").paginate :page => @page, :per_page => @per_page#, :include => :tags
        @assets = Asset.with_ids(asset_ids).tagged_with_any(pid_tag_list).tagged_with_any(task_tag_list).with_subtype(@subtypes).with_locale(@locale).with_fulltext(@keywords).with_access(@access_level).order_by(@order,"desc").paginate :page => @page, :per_page => @per_page#, :include => :tags
      else
        @assets = Asset.with_ids([]).paginate :page => @page, :per_page => @per_page
      end
      @total_entries = @assets.total_entries

      }.to_s]
      ben << ["REF007", Benchmark.ms {

      # logger.info "@assets=#{@assets.inspect}; @total_entries=#{@total_entries}"
      @product_name = PRODUCT_MAPPING[pid]
      # logger.info "Pagination: page=#{@page}, per_page=#{@per_page}, total_entries=#{@assets.total_entries}, total_pages=#{@assets.total_pages}"

      products = Tag.with_namespace('product').with_key('pid').for_assets(asset_ids)

      }.to_s]
      ben << ["REF008", Benchmark.ms {
      
      tasks = Tag.with_namespace('documentation').with_key('task').for_assets(asset_ids)

      }.to_s]
      ben << ["REF009", Benchmark.ms {

      # TODO - URL friendly names to be provided by Product Master
      # counter for products
      task_tag_list = @tasks.map{|p| "documentation:task=#{p}"}.join(" ")

      }.to_s]
      ben << ["REF010", Benchmark.ms {
      
      tmp_tags =  Tag.for_assets(Asset.only_ids.with_ids(asset_ids).tagged_with_any(task_tag_list).with_subtype(@subtypes).with_locale(@locale).with_fulltext(@keywords).with_access(@access_level)).count('name', :group => "tags.name")

      }.to_s]
      ben << ["REF011", Benchmark.ms {

      tags={}
      tmp_tags.each do |t|
        tags[t[0]] = t[1]
      end

      }.to_s]

      def product_facet(pid, ltags)
        {:dname => PRODUCT_MAPPING[pid.to_i],
          :uname => url_friendly(PRODUCT_MAPPING[pid.to_i]),
          :count => ltags["product:pid=#{pid}"]||0
        }
      end


      ben << ["REF012", Benchmark.ms {

      # tasks = []
        @f_products = (products.map(&:value)|[]).map{ |pid| 
          pid.to_i == PID_FOR_TEST ? nil : product_facet(pid, tags)
          }.compact.sort_by{ |a| 
            a[:dname]
          }
          @f_products.insert 0, product_facet(PID_FOR_TEST, tags)
        # logger.info "f_products=#{@f_products.inspect}"



        }.to_s]
        ben << ["REF013", Benchmark.ms {


        pid_tag_list = @product_keys.map{|p| "product:pid=#{p}"}.join(" ")
        task_tag_list = @tasks.map{|p| "documentation:task=#{p}"}.join(" ")

        }.to_s]
        ben << ["REF014", Benchmark.ms {

        # counter for types
        tmp_subtypes =  Asset.with_ids(asset_ids).tagged_with_any(pid_tag_list).tagged_with_any(task_tag_list).with_locale(@locale).with_fulltext(@keywords).with_access(@access_level).count('da_subtype', :group => "assets.da_subtype")

        }.to_s]
        ben << ["REF015", Benchmark.ms {

        subtypes={}
        tmp_subtypes.each do |t|
          subtypes[t[0]] = t[1]
        end

        }.to_s]
        ben << ["REF016", Benchmark.ms {
        
            # tasks = []
              @f_subtypes = DOC_SUBTYPES.map { |subtype| 
                {:dname => subtype,
                  :uname => url_friendly(subtype),
                  :count => subtypes[subtype]||0
                }
                }.sort_by{ |a| 
                  a[:dname]
                }


                }.to_s]
                ben << ["REF017", Benchmark.ms {

          # counter for tasks
          pid_tag_list = @product_keys.map{|p| "product:pid=#{p}"}.join(" ")
          

          }.to_s]
          ben << ["REF018", Benchmark.ms {

          logger.info "Tags: asset_ids=#{asset_ids.inspect}; pid_tag_list=#{pid_tag_list.inspect} @subtypes=#{@subtypes.inspect}"
          
          }.to_s]
          ben << ["REF019", Benchmark.ms {


          tmp_tags =  Tag.for_assets(Asset.only_ids.with_ids(asset_ids).tagged_with_any(pid_tag_list).with_subtype(@subtypes).with_locale(@locale).with_fulltext(@keywords).with_access(@access_level)).count('name', :group => "tags.name")

          }.to_s]
          ben << ["REF020", Benchmark.ms {


          tags={}
          tmp_tags.each do |t|
            tags[t[0]] = t[1]
          end

          supported_tasks=TASKS.map{|t|t.downcase}

          }.to_s]

          logger.info "%%%%%%%%%%%%%%%% Tags response=#{tmp_tags.inspect}"
          logger.info "%%%%%%%%%%%%%%%% Tasks=#{tasks.inspect}"
          logger.info "%%%%%%%%%%%%%%%% Extracted tags=#{tags.inspect}"
          logger.info "%%%%%%%%%%%%%%%% supported_tasks=#{supported_tasks.inspect}"
          logger.info "%%%%%%%%%%%%%%%% TASKS=#{TASKS.inspect}"

          ben << ["REF021", Benchmark.ms {

              # tasks = []
                @f_tasks = ((tasks.map(&:value)|[]) & supported_tasks).map{ |task|
                  logger.info "task=#{task.inspect}; uname=#{url_friendly(task)}"

                  {:dname => task.capitalize,
                    :uname => url_friendly(task),
                    :count => tags["documentation:task=#{task}"]||0
                  }
                  }.sort_by { |a| a[:dname] }

                  }.to_s]

            respond_to do |format|
              format.html {
                logger.info "Replying HTML"
              }
              format.xml {
                logger.info "Replying XML"
              }
              format.json { 
                headers["Content-Type"] = "text/javascript;"
                res = { 
                  :assets => @assets.map{|asset| asset_to_hash(asset, :locale => @locale, :keywords => @keywords)}, 
                  :meta => {
                    :page => @page,
                    :product_name => @product_name, 
                    :per_page => @per_page, 
                    :total_entries => @total_entries,
                    :order => @order,
                    :locale => @locale
                    },
                    :filters => {},
                    :f_tasks => @f_tasks,      
                    :f_subtypes => @f_subtypes,
                    :f_products => @f_products 
                  }                            
                  @subtypes.map
                  res[:filters][:product] = @products.join(',')  unless @products.empty?
                  res[:filters][:subtype] = @subtypes.map{|s| url_friendly s}.join(',')  unless @subtypes.empty?
                  res[:filters][:task] = @tasks.map{|t| url_friendly t}.join(',')        unless @tasks.empty?
                  res[:filters][:search] = @keywords.join(' ')   unless @keywords.empty?
                  # logger.info "JSON RESPONSE=#{res.to_xml}"
                  render :json => res
                }
              end

ben.each { |b| logger.info b.join(' ') }

            end

private

def asset_to_hash(asset,options={})
  options.reverse_merge! :locale => @locale, :keywords => []
  { :access_level => asset.access_level, 
    :locale => options[:locale],
    :da_type => asset.da_type,
    :da_subtype => asset.da_subtype,
    :published_at => asset.published_at.to_i,
    :expire_at => asset.expire_at.to_i,        
    :xid => asset.xid,
    :title => asset.title(options[:locale]),
    :abstract => asset.abstract(options[:locale]),
    :hxid => highlight(asset.xid,options[:keywords]),
    :htitle => highlight(asset.title(options[:locale]),options[:keywords]),
    :habstract => highlight(asset.abstract(options[:locale]),options[:keywords]),
    :short_title => asset.short_title(options[:locale]),
    :link => asset_url("#{asset.sid}_#{url_friendly(asset.title(@locale))}")
     }
end

  
end
