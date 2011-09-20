require 'open-uri'
require 'faster_csv'


module Seeding

  # def self.refresh_releases(options                      = {})
  #   options.reverse_merge! :full                         => :false
  # 
  #   Release.delete_all if options[:full]
  # 
  #   open("http://localhost:3050/releases.json") do |releases|
  #     pm_releases                                        = JSON.parse releases.read
  #     pm_releases.each do |pm_release|
  # 
  #       # puts "#{release["product_name"]} #{release["full_label"]}"
  # 
  #       release                                          = {
  #         :key                                           => pm_release["key"].gsub(/(-0)/,''), 
  #         :pname                                         => pm_release["product_name"],
  #         :rlabel                                        => pm_release["full_label"]}
  # 
  #         # puts "key                                    = #{Release.pid_condition release[:key]}"
  #         levels                                         = release[:key].split('-')
  #         release[:pid]                                  = levels[0]
  #         release[:pid_a]                                = [levels[0],levels[1]].join("-") unless levels[1].nil?
  #         release[:pid_ab]                               = [levels[0],levels[1],levels[2]].join("-") unless levels[2].nil?
  #         release[:pid_abc]                              = [levels[0],levels[1],levels[2],levels[3]].join("-") unless levels[3].nil?
  #         release[:pid_abcd]                             = [levels[0],levels[1],levels[2],levels[3],levels[4]].join("-") unless levels[4].nil?
  #         r                                              = Release.create(release)
  #         r.errors.to_a.each {|e| puts "Error: #{e.join(" ")}: #{r.inspect}"}
  #       end
  #     end
  #   end

    # def self.create_users
    #   %W( herve bill jane tom angie bob ).each { |name|
    #     puts "creating user #{name}"
    #            User.find_or_create_by_username ( :locale => "en_US", :username => name, :email => "#{name}@xyz.net", :password => "#{name}123").save!
    #      }
    # end

    ACCESS_LEVELS                                          = [10,10,10,10,10,10,10,10,20,20,30,40,50,50,50]
    POPULARITY_MAX                                         = 100
    RANDOM_TAG                                             = %w( Documentation Tutorial Backup API Aix hpux Solaris Redhat Linux MacOS Windows doc:topic=Develop doc:topic=Troubleshoot doc:topic=Install doc:topic=Configure doc:topic=Install doc:topic=Troubleshoot doc:topic=Upgrade Troubleshooting dot_net 2008 3d advertising ajax and animation api apple architecture art article articles artist audio blog blogging blogs book books browser business car cms code collaboration comics community computer converter cooking cool css culture data database design Design desktop development diy documentation download downloads drupal ebooks economics education electronics email entertainment environment fashion fic film finance firefox flash flex flickr food forum free freeware fun funny gallery game games geek google government graphics green guide hardware health history home hosting house howto html humor icons illustration images imported information inspiration interactive interesting internet iphone japan java javascript jobs jquery kids language learning library linux list lists literature mac magazine management maps marketing math media microsoft mobile money movie movies mp3 music network networking news online opensource osx people phone photo photography photos photoshop php plugin podcast politics portfolio privacy productivity programming psychology python radio rails realestate recipe recipes reference religion research resources reviews rss ruby rubyonrails school science search security seo shop shopping social socialnetworking software statistics streaming teaching tech technology tips todo tool tools toread travel tutorial tutorials tv twitter typography ubuntu usability video videos vim visualization web web20 webdesign webdev wiki wikipedia windows wishlist wordpress work writing youtube )
    

    def self.random_access_level
      ACCESS_LEVELS[rand(ACCESS_LEVELS.length)]
    end

    def self.random_product
      DocumentationsController::ALL_PIDS_FOR_TEST[rand(DocumentationsController::ALL_PIDS_FOR_TEST.length)]
    end

    def self.random_popularity
      para_random POPULARITY_MAX, 3
    end

    def self.para_random(size, power=2)
      (rand**power*size).to_i
    end

    def self.create_asset(number, asset_attr, options)
      translations                                         = asset_attr.delete(:translations)
      releases                                             = asset_attr.delete(:releases)
      tags                                                 = asset_attr.delete(:tags)

      asset_attr[:sid]                                     = asset_attr[:sid]+number.to_s
      asset_attr[:published_at]                            = (rand*100000).to_i.minutes.ago
      asset_attr[:expire_at]                               = asset_attr[:published_at].years_since 2
      asset_attr[:is_deleted]                              = false
      asset_attr[:status]                                  = 1
      # asset_attr[:access_level]                          = random_access_level
      asset_attr[:popularity]                              = random_popularity

      if options[:full]
        a                                                  = Asset.find_by_sid asset_attr[:sid]
        a.destroy if a
      end

      a                                                    = Asset.find_and_update_or_create_by_sid asset_attr

      # tags                                               = []
      6.times do |i|
        tags << RANDOM_TAG[(rand*RANDOM_TAG.length/3).to_i]
      end
      tags                                                 = tags | []
      a.tag_names                                          = tags.join(' ')

      a.save

      a.translations.each { |t| t.destroy }
      translations.each do |translation|
        translation[:short_title]                          = translation[:short_title] + number.to_s
        translation[:title]                                = translation[:title] + number.to_s
        a.translations.build(translation).save
      end 
    end

  def self.url_friendly(a)
    a.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-')
  end

  def self.create_tag(name, user)
    tag     = nil
    begin
      tag = Tag.find_or_create_by_name_with_creator(name, user.id )
      tag.update_attributes :is_approved => true, :is_reviewed => true, :reviewer => user, :reviewed_at => Time.now
    rescue
      puts "Exception! tag=#{tag.inspect}"
      puts "All error messages: #{tag.errors.full_messages.join(', ')}" unless tag.nil?
    end
  end
  
  def self.load_users(file)
    puts "Loading Users..."

    Subscription.destroy_all
    Inbox.destroy_all

    header=nil
    FasterCSV.foreach(file) do |row|
      if header.nil?
        header = row 
      else
        new_user_attr = {}
        header.each_with_index do |h,i|
          new_user_attr[h.to_sym] = row[i] unless row[i].nil?
        end


        if new_user_attr[:username]=='system'
          puts "Choose a password for user 'system':"  
          STDOUT.flush  
          new_user_attr[:password] = STDIN.gets.chomp
        else
          new_user_attr[:password] = "#{new_user_attr[:username]}123"
        end
        
        # puts "loading user #{new_user_attr.inspect}"
        user = User.create! new_user_attr
        
        # handle attributes blocked from mass-assignment
        %w( role reputation is_admin access_level is_deleted ).each do |attr|
          user[attr.to_sym] = new_user_attr[attr.to_sym] unless new_user_attr[attr.to_sym].nil?
        end
        
        user.save
        Inbox.create :name => "#{user.firstname}'s inbox", :owner => user
        # puts "user = #{user.inspect}"
      end
    end
  end

  def self.load_assets(file)

      puts "Loading Assets..."
      # Asset.destroy_all

      @user = User.find_by_username "system"

      # all_products_by_pid = DocumentationsController::LONG_PRODUCT_MAPPING
      all_products_by_name  = {}
      DocumentationsController::LONG_PRODUCT_MAPPING.each do |product|
        all_products_by_name[product[1]] = product[0]
      end

      # puts "all_products_by_name = #{all_products_by_name.inspect}"
      # return

      expected_header = "Language Code,Source,Sid,Xid,Title,Display Date,SHORT TITLE,Abstract,Content Type (AG),Processed Offname Text,Processed Offering version Number,Support Zone Access Level,Doc Type,Keywords,Admin,Config,Install,Using,Troubleshoot,Plan,Maintain,Customize,Optimize"
      expected_header = FasterCSV.parse(expected_header)[0]
      # puts "header  = #{header.inspect}"

      # header        = %w(Language Name Title Display Date SHORT TITLE Abstract Content Type (AG) Processed Offname Text Processed Offering version Number Support Zone Access Level Doc Type General Admin Config Install Using Troubleshoot Plan Maintain Customize Optimize)

      @error = nil;
      header = nil;
      FasterCSV.foreach(file) do |row|
        # FasterCSV.foreach("data/seeding/Nayworker.csv") do |row|
        # FasterCSV.parse(csv_data) do |row| #puts row.class

        if header.nil?
          header = row
          @error = (header != expected_header)
        else

          if @error 
            puts "** Aborting! Incorrect header in #{file}."
            puts " Expected #{header.inspect}"
            puts " Found    #{row.inspect}"
            return
          else
            # row.each_with_index {|r,i| puts "#{i}: #{r}"}
            # puts "row                                            = #{row.inspect}"

            asset_attr                                           = {
              # :sid                                                 => "doc#{docid}",
              :source                                              => row[1],
              :sid                                                 => row[2],
              :xid                                                 => row[3],
              :da_type                                             => row[8],
              :da_subtype                                          => row[12],
              :entitlement_model                                   => 1,                 # access_level
              :entitlement_value                                   => row[11].to_i
            }

            translations                                         = [
              {:locale                                         => row[0],
                :short_title                                   => row[6],
                :title                                         => row[4],
                :abstract                                      => row[7]
              }
            ]

            pid                         = all_products_by_name[row[9]]
            version                     = "product:version=#{url_friendly row[10]}" unless row[10].blank?
            # puts "row[7]              = #{row[7]}; pid=#{pid}; row[8]=(#{row[8]}); version=(#{version}) row=#{row.inspect}"

            tags = row[14..22].compact.map{|t| "documentation:task=#{t}"}
            tags << version unless pid.blank?
            tags << "product:pid=#{pid}" unless pid.blank?
            tags << row[13] # keywords

  # puts "tags=#{tags.join(' ')}"

            asset_attr[:published_at]   = row[5].to_date # (rand*100000).to_i.minutes.ago
            asset_attr[:expire_at]      = asset_attr[:published_at].years_since 10
            asset_attr[:is_deleted]     = false
            # asset_attr[:status]       = 1
            # asset_attr[:access_level] = random_access_level
            asset_attr[:popularity]     = random_popularity
            # asset_attr[:translations]   = translations
            # puts "asset = #{asset_attr.inspect}"
            # puts "translations = #{translations.inspect}"
            a                           = Asset.find_and_update_or_create_by_sid asset_attr
            a.save

            # puts "New Asset saved: #{a.inspect}"

            # a.tag_names               = tags.join(' ')
            # puts "a.tag_names         = #{a.tag_names}"

            # a.translations.each { |t| t.destroy }
            translations.each do |translation|
              a.translations.build(translation) #.save
            end 
            a.save

             a.bookmarks.build :title => a.title('en_US'), :user_id => @user.id, :all_tags => tags.join(' '), :is_system => true
             a.save

            # a.bookmarks.build :user_id => User.last.id, :title => a.title('en_US'), :all_tags=>"a b c x:y=z"
            # a.save

            # docid += 1
          end
        end
      end
    end

  def self.load_tags(file)
    puts "Loading Tags..."

    # Tag.destroy_all

    @user = User.find_by_username "system"
    if @user.nil? then
      puts "Username system not found"
      exit
    end

      FasterCSV.foreach(file) do |row|

        create_tag row[0], @user

    end
  end

  def self.load_service_requests(file)
    puts "Loading Service Requests..."


    header=nil
    FasterCSV.foreach(file) do |row|
      if header.nil?
        header = row 
      else
        new_service_request_attr = {}
        invalid_record = false

        header.each_with_index do |h,i|
          
          case h
          when "owner"
            user = User.find_by_username(row[i])
            if user
              new_service_request_attr["owner_id"] = user.id
            else
              puts "** Skipping service request for owner #{row[i]}: User not found"
              invalid_record = true
            end
          when "contact"
            user = User.find_by_username(row[i])
            if user
              new_service_request_attr["contact_id"] = user.id
            else
              puts "** Skipping service request for contact #{row[i]}: User not found"
              invalid_record = true
            end
          when "site"
            site = Site.find_by_site_id(row[i])
            if site
              new_service_request_attr["site_id"] = site.id
            else
              puts "** Skipping service request for site #{row[i]}: Site not found"
              invalid_record = true
            end
          else
            new_service_request_attr[h.to_sym] = row[i] unless row[i].nil?
          end
        end

        # puts "before creating service_request #{new_service_request_attr.inspect}"
        service_request = ServiceRequest.create! new_service_request_attr unless invalid_record
        # puts "after creating service_request #{service_request.inspect}"

        # handle attributes blocked from mass-assignment
        # %w( reputation is_admin access_level is_deleted ).each do |attr|
        #   user[attr.to_sym] = new_user_attr[attr.to_sym] unless new_user_attr[attr.to_sym].nil?
        # end
        begin
          service_request.save
          service_request.update_watcher
        rescue
          puts "Exception! service_request=#{row.inspect}"
          puts "All error messages: #{service_request.errors.full_messages.join(', ')}" unless service_request.nil?
        end
        # puts "user = #{user.inspect}"
      end
    end
  end
  

def self.load_notes(file)
  puts "Loading Notes..."

  header=nil
  created_at = 1.hour.ago
  FasterCSV.foreach(file) do |row|
    if header.nil?
      header = row 
    else
      new_note_attr = {}
      invalid_record = false

      header.each_with_index do |h,i|
        
        case h
        when "created_by"
          user = User.find_by_username(row[i])
          if user
            new_note_attr["created_by"] = user.id
          else
            puts "** Skipping note created by #{row[i]}: User not found"
            invalid_record = true
          end
        when "sr_number"
          service_request = ServiceRequest.find_by_sr_number(row[i])
          if service_request
            new_note_attr["service_request_id"] = service_request.id
          else
            puts "** Skipping note for sr_number #{row[i]}: Service Request not found"
            invalid_record = true
          end
        when "created_at"
          # puts "setting updated_at to #{row[i]}"
          # new_note_attr["updated_at"] = row[i]
          created_at = row[i]
          # new_note_attr["created_at"] = row[i]
        else
          new_note_attr[h.to_sym] = row[i] unless row[i].nil?
        end
      end

      # puts "before creating note #{new_note_attr.inspect}"
      note = Note.create! new_note_attr unless invalid_record
      
      note[:created_at] = created_at
      note[:updated_at] = created_at
      # puts "after creating note #{note.inspect}"
      
      # handle attributes blocked from mass-assignment
      # %w( reputation is_admin access_level is_deleted ).each do |attr|
      #   user[attr.to_sym] = new_user_attr[attr.to_sym] unless new_user_attr[attr.to_sym].nil?
      # end
      begin
        note.save
      rescue
        puts "Exception! note=#{row.inspect}"
        puts "All error messages: #{note.errors.full_messages.join(', ')}" unless note.nil?
      end
      # puts "user = #{user.inspect}"
    end
  end
end

def self.load_sites(file)
  puts "Loading Sites..."

  header=nil
  FasterCSV.foreach(file) do |row|
    if header.nil?
      header = row 
    else
      new_note_attr = {}
      header.each_with_index do |h,i|
        new_note_attr[h.to_sym] = row[i] unless row[i].nil?
      end
      site = Site.create! new_note_attr

      # handle attributes blocked from mass-assignment
      # %w( reputation is_admin access_level is_deleted ).each do |attr|
      #   user[attr.to_sym] = new_user_attr[attr.to_sym] unless new_user_attr[attr.to_sym].nil?
      # end
      begin
        site.save
      rescue
        puts "Exception! site=#{row.inspect}"
        puts "All error messages: #{site.errors.full_messages.join(', ')}" unless site.nil?
      end
      # puts "user = #{user.inspect}"
    end
  end
end
=begin
      0:  [Language Code                    ] = en_US
      1:  [Sid                              ] = 300-006-401_a02_elccnt_0.pdf
      2:  [Xid                              ] = 300-006-401_a02_elccnt_0.pdf
      3:  [Title                            ] = Getting Started - Nayworker Fast Start 7.4 SP2
      4:  [Display Date                     ] = 4/1/2008 0:00
      5:  [SHORT TITLE                      ] = Getting Started Nayworker 7.4 SP2
      6:  [Abstract                         ] = This doc provides the installation steps and the prerequisites for the Nayworker Fast Start software.
      7:  [Content Type (AG)                ] = 
      8:  [Processed Offname Text           ] = Nayworker
      9:  [Processed Offering version Number] = 7.4 SP2
      10:  [Support Zone Access Level       ] = 10
      11: [Doc Type                         ] = Getting Started
      12: [General                          ] = 
      13: [Admin                            ] = 
      14: [Config                           ] = Configure
      15: [Install                          ] = Install
      16: [Using                            ] = 
      17: [Troubleshoot                     ] = 
      18: [Plan                             ] = 
      19: [Maintain                         ] = 
      20: [Customize                        ] = 
      21: [Optimize                         ] = 
=end    

  DOC_TITLES = {}
  DOC_TITLES['en_US'] = ["There are only two kinds of languages: the ones people complain about and the ones nobody uses.",
    "Some people, when confronted with a problem, think \"I know, I'll use regular expressions.\" Now they have two problems.",
    "Java is to javaScript what Car is to Carpet.",
    "Benchmarks don’t lie, but liars do benchmarks.",
    "In theory, there is no difference between theory and practice. But, in practice, there is.",
    "The hardest part of design is keeping features out.",
    "Why do we never have time to do it right, but always have time to do it over?",
    "Bad code isn’t bad, its just misunderstood.",
    "When a programming language is created that allows programmers to program in simple English, it will be discovered that programmers cannot speak English.",
    "Before software can be reusable it first has to be usable.",
    "Software and cathedrals are much the same – first we build them, then we pray.",
    "If debugging is the process of removing bugs, then programming must be the process of putting them in.",
    "Walking on water and developing software from specification are easy if both are frozen.",
    "Once a new technology starts rolling, if you’re not part of the steamroller, you’re part of the road.",
    "Never trust a computer you can't throw out a window.",
    "Measuring programming progress by lines of code is like measuring aircraft building progress by weight.",
    "The first 90% of the code accounts for the first 90% of the development time. The remaining 10% of the code accounts for the other 90% of the development time.",
    "Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it.",
    "'User' is a word used by computer professionals when they mean idiot."]

    DOC_TITLES['fr_FR'] = ["Les cons ça ose tout, c’est même à ça qu’on les reconnaît.",
    "Les ordres sont les suivants : on courtise, on séduit, on enlève et en cas d’urgence…on épouse.",
    "Quand les types de 130 kilos disent certaines choses, ceux de 60 kilos les écoutent.",
    "La tête dure et la fesse molle... le contraire de ce que j’aime.",
    "Un pigeon, c’est plus con qu’un dauphin, d’accord... mais ça vole.",
    "Mais pourquoi j’m'enerverais ? Monsieur joue les lointains ! D’ailleurs je peux très bien lui claquer la gueule sans m’énerver !",
    "Quand on mettra les cons sur orbite, t’as pas fini de tourner.",
    "La justice c’est comme la Sainte Vierge. Si on la voit pas de temps en temps, le doute s’installe.",
    "Si la connerie n’est pas remboursée par les assurances sociales, vous finirez sur la paille.",
    "Deux intellectuels assis vont moins loin qu’une brute qui marche.",
    "Vous savez quelle différence il y’a entre un con et un voleur ? Un voleur de temps en temps ça se repose.",
    "Dans la vie, il faut toujours être gentil avec les femmes... même avec la sienne.",
    "Je suis pas contre les excuses... je suis même prêt à en recevoir.",
    "Il vaut mieux s’en aller la tête basse que les pieds devant.",
    "Quand on a pas de bonne pour garder ses chiards, eh bien on en fait pas.",
    "Plus t’as de pognon, moins t’as de principes. L’oseille c’est la gangrène de l’âme.",
    "Deux milliards d’impôts ? J’appelle plus ça du budget, j’appelle ça de l’attaque à main armée.",
    "Je suis ancien combattant, militant socialiste et bistrot... C’est dire si, dans ma vie, j’en ai entendu, des conneries.",
    "Le flinguer, comme ça, de sang froid, sans être tout à fait de l’assassinat, y’aurait quand même comme un cousinage.",
    "A travers les innombrables vicissitudes de la France, le pourcentage d’emmerdeurs est le seul qui n’ait jamais baissé."]

  def self.random_title(locale='en_US')
    DOC_TITLES[locale][(rand*DOC_TITLES[locale].length).to_i] + " / " + (1000000000+rand(8900000000)).to_s
  end

  def self.create_dummy_assets(options = {})
    options.reverse_merge! :prefix => 'docu', :id_base => 1500, :size => 10, :da_type => 'documentation', :da_subtype => 'Manual and Guides', :locale => 'en_US'

    puts "Creating #{options[:size]} dummy assets"

    @user = User.find_by_username "system"
    if @user.nil? then
      puts "User system not found"
      exit
    end
    options[:size].times { |i|
      sid = "#{options[:prefix]}#{options[:id_base]+i}"
      # puts "loading #{sid} with #{random_title}"
      asset_attr                                           = {
        :source                                              => "auto",
        :sid                                                 => sid,
        :xid                                                 => sid,
        :da_type                                             => options[:da_type],
        :da_subtype                                          => options[:da_subtype],
        :entitlement_model                                   => 1,                 # access_level
        :entitlement_value                                   => random_access_level
      }

      translations                                         = [
        {:locale                                         => options[:locale],
          :short_title                                   => '',
          :title                                         => random_title(options[:locale]),
          :abstract                                      => ''
        }
      ]

      pid                         = random_product
      # version                     = "product:version=#{url_friendly row[10]}" unless row[10].blank?
      # puts "row[7]              = #{row[7]}; pid=#{pid}; row[8]=(#{row[8]}); version=(#{version}) row=#{row.inspect}"

      # tags = []
      # tags = row[14..22].compact.map{|t| "documentation:task=#{t}"}
      # tags << version unless pid.blank?
      # tags << "product:pid=#{pid}" unless pid.blank?
      # tags << row[13] # keywords

      # puts "tags=#{tags.join(' ')}"

      asset_attr[:published_at]                            = (rand*100000).to_i.minutes.ago
      asset_attr[:expire_at]                               = asset_attr[:published_at].years_since 2
      asset_attr[:is_deleted]     = false
      # asset_attr[:status]       = 1
      # asset_attr[:access_level] = random_access_level
      asset_attr[:popularity]     = random_popularity
      # asset_attr[:translations]   = translations
      # puts "asset = #{asset_attr.inspect}"
      # puts "translations = #{translations.inspect}"
      a                           = Asset.find_and_update_or_create_by_sid asset_attr
      a.save

      # puts "New Asset saved: #{a.inspect}"

      # a.tag_names               = tags.join(' ')
      # puts "a.tag_names         = #{a.tag_names}"

      # a.translations.each { |t| t.destroy }
      # a.translations.each do |t|
      #   t.destroy
      # end
      
      # puts "Before a.translations (#{a.translations.size}) = #{a.translations.inspect}"
      translations.each do |translation|
        existing_translation = Translation.find_by_asset_id_and_locale a.id, translation[:locale]
        a.translations.destroy existing_translation.id unless existing_translation.nil?
        # a.translations.reject!{ |t| 
          # puts "#{a.sid}: #{t[:locale]} == #{translation[:locale]} = #{t[:locale]==translation[:locale]}"
          # t[:locale]==translation[:locale]
          # }
      # end 
      # a.save

      # translations.each do |translation|
        a.translations.build(translation) #.save
      end 
      a.save
      # puts "After a.translations (#{a.translations.size}) = #{a.translations.inspect}"

      # a.bookmarks.build :title => a.title(options[:locale]), :user_id => @user.id, :all_tags => tags.join(' '), :is_system => true
      # a.save
      
      @start_time ||= Time.now
      if i.modulo(100) == 0 && i > 0
        current_time = Time.now
        puts "Created #{i} assets out of #{options[:size]} - Est. ending at #{(current_time+((current_time-@start_time).to_f/i*(options[:size]-i)).to_i).strftime("%I:%M:%S%p")}"
      end
    }
  end

  def self.create_dummy_users(options = {})
    options.reverse_merge! :size => 10, :prefix => 'auto', :start_index => 100000

    puts "Creating #{options[:size]} dummy users..."
    new_user={}
    index=options[:start_index]
    options[:size].times {

      begin
        new_user[:username]  = options[:prefix]+index.to_s
        new_user[:firstname] = 'first'+index.to_s
        new_user[:lastname]  = 'last'+index.to_s
        new_user[:email]     = 'email'+index.to_s+'@auto.com'
        new_user[:password]  = "#{new_user[:username]}123"

        user = User.find_by_username new_user[:username]
        if user.nil?
          user = User.new new_user
        else
          user.update_attributes(new_user)              
        end
        user.save!
        # puts "Saved user #{user.inspect}"
      rescue
        puts "Exception! user=#{user.inspect}"
        puts "All error messages: #{user.errors.full_messages.join(', ')}" unless user.nil?
      end
      index += 1
    }

  end

  DUMMY_TAGS = %w(animals   architecture   art   asia   australia   autumn   baby   band   barcelona   beach   berlin   bike  
    bird   birds   birthday   black   blue   california   canada   canon   car   cat   chicago   china   christmas   church  
    city   clouds   color   concert   dance   day   dog   england   europe   fall   family   fashion   festival   film   florida 
    flower   flowers   food   football   france   friends   fun   garden     germany   graffiti   green   halloween   hawaii  
    holiday   home   house   india   iphone   ireland   island     italy   japan   kids   la   lake   landscape   light  
    live   london   love   macro   me   mexico   model   mountain   mountains   museum   music   nature   new   newyork  
    newyorkcity   night      ocean   old   paris   park   party   people   photo   photography   photos   portrait   raw  
    red   river   rock      sanfrancisco   scotland   sea   seattle   show   sky   snow   spain   spring   street   summer 
    sun   sunset   taiwan   texas   thailand   tokyo   toronto   tour   travel   tree   trees   trip   uk   urban   usa 
    vacation   vancouver   washington   water   wedding   white   winter   yellow   york   zoo)

  def self.dummy_tag(options = {})
    options.reverse_merge! :size => 10, :users => 10

    puts "Tagging assets..."

    @user = User.find_by_username "system"
    if @user.nil? then
      puts "User system not found"
      exit
    end

    DUMMY_TAGS.each { |name|
      create_tag name, @user
    }

    all_users = User.active_normal.only_ids.limit(options[:users]).collect(&:id)
    all_tags = Tag.user_tags.collect(&:name)
    all_assets = Asset.find(:all, :select => 'id', :conditions => ["assets.source = 'auto'"]).collect(&:id)

    uindexes=[]
    (all_users.size-1).times {
      uindexes << para_random(options[:size],3)
    }
    uindexes << options[:size]
    uindexes.sort!

    # puts "uindexes=#{uindexes.inspect}"

    start_uindex=1
    total=0
    uindexes.each_with_index { |uindex,i|
      nb = uindex-start_uindex+1
      start_uindex = uindex+1
      total += nb
      uid = all_users[i]
      nb.times {
        puts "Should not be here! user=#{uid} - nb=#{nb}" if nb==0
        nb_tags = 2 + rand(5).to_i
        tags = []
        nb_tags.times {
          tags << all_tags[para_random(all_tags.size,3)]
        }
        tags.uniq!

        # new_attr[h.to_sym] = row[i] unless row[i].nil?



        begin
          a = Asset.find all_assets[para_random(all_assets.size)]
          # puts "Tagging asset #{a.id} with [#{tags.join(' ')}]"
          new_attr = {}
          new_attr["user_id"] = uid
          new_attr["asset_id"] = a.id
          new_attr["title"] = Asset.find(a.id).title('en_US')
          new_attr["all_tags"] = tags.join(' ')
          bookmark = Bookmark.find_by_user_id_and_asset_id new_attr["user_id"], new_attr["asset_id"]
          if bookmark.nil?
            bookmark = Bookmark.new new_attr
          else
            bookmark.update_attributes(new_attr)              
          end
          bookmark.save!
        rescue
          puts "Exception! bookmark=#{bookmark.inspect}"
          puts "All error messages: #{bookmark.errors.full_messages.join(', ')}" unless bookmark.nil?
        end
      }
      puts "User #{uid} created #{nb} bookmarks"
    }    
    puts "#{total} bookmarks were created in total"
  end
  


  def self.load_bookmarks(file)
    puts "Loading Bookmarks..."

    # Bookmark.destroy_all
    header=nil

    FasterCSV.foreach(file) do |row|
      if header.nil?
        header              = row 
      else
        new_attr = {}
        user     = nil
        header.each_with_index do |h,i|
          case h
          when "username"
            user = User.find_by_username(row[i])
            if user
              new_attr["user_id"] = user.id
            else
              puts "** Skipping bookmark for user=#{row[i]}: User not found"
            end
          when "xid"
            asset = Asset.find_by_xid(row[i])
            # puts "xid=#{row[i]}; asset=#{asset.inspect}"
            if asset
              new_attr["asset_id"] = asset.id
              new_attr["title"] = asset.title('en_US')
            else
              puts "** Skipping bookmark for xid=#{row[i]}: Asset not found"
            end
          else
            new_attr[h.to_sym] = row[i] unless row[i].nil?
          end
          # puts "h=#{h.inspect}; row=#{row.inspect}"
        end
        if new_attr["asset_id"]
          # puts "new_attr=#{new_attr.inspect}"
          begin
            bookmark = Bookmark.find_by_user_id_and_asset_id new_attr["user_id"], new_attr["asset_id"]
            if bookmark.nil?
              bookmark = Bookmark.new new_attr
            else
              bookmark.update_attributes(new_attr)              
            end
            bookmark.save!
          rescue
            puts "Exception! bookmark=#{bookmark.inspect}"
            puts "All error messages: #{bookmark.errors.full_messages.join(', ')}" unless bookmark.nil?
          end
          # handle attributes blocked from mass-assignment
          # %w( is_system ).each do |attr|
          #   bookmark[attr.to_sym] = new_attr[attr.to_sym] unless new_attr[attr.to_sym].nil?
          # end
        end
      end
    end
  end
end

# Thorough DB clean up
Subscription.destroy_all
InboxSr.destroy_all
APN::Notification.destroy_all
APN::Device.destroy_all
C2dm::Notification.destroy_all
C2dm::Device.destroy_all

# Then clean up data that we will reload
User.destroy_all
Tag.destroy_all
Asset.destroy_all
TopTag.destroy_all
Bookmark.destroy_all
Site.destroy_all
ServiceRequest.destroy_all
Note.destroy_all

# reload all data
Seeding.load_users "db/data/users.csv"
Seeding.load_tags "db/data/tags.csv"
Seeding.load_assets "db/data/assets.csv"
Seeding.load_bookmarks "db/data/bookmarks.csv"
Seeding.load_sites "db/data/sites.csv"
Seeding.load_service_requests "db/data/service_requests.csv"
Seeding.load_notes "db/data/notes.csv"






# BEFORE DROPPING TABLES, RETAIN APP DEFINITION
# -- open ./script/console
# a=APN::App.first
# -- then recreate the schema
# reload!
# b=APN::App.new;b.apn_dev_cert=a.apn_dev_cert;b.apn_prod_cert=a.apn_prod_cert;b.save


# Seeding.create_dummy_users :size => 200, :start_index => 100000

# Seeding.create_dummy_assets :prefix => 'docu', :id_base => 4000, :size => 1000
# Seeding.create_dummy_assets :prefix => 'docu', :id_base => 4000, :size => 1000, :locale => 'fr_FR'

# Seeding.dummy_tag :size=>10, :users => 1000

# Asset.destroy_all
# TopTag.destroy_all
# Bookmark.destroy_all
# Seeding.load_docs "db/data/small_Nayworker.csv"
# Seeding.load_bookmarks "db/data/small_bookmarks.csv"
