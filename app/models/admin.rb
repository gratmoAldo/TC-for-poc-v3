class Admin < ActiveRecord::Base
  attr_accessible :key, :value

  def self.method_missing(name, *args)
    lname = name.to_s
    return super unless lname.first=='_'
    lname.slice! 0
    a = Admin.find :first, :conditions => {:key => lname}
    if args.empty?
      a.nil? ? nil : a.value
    else
      if a.nil?
        Admin.create! :key => lname, :value => args.first
      else
        a.update_attributes! :value => args.first
      end
      args.first
    end
  end
end
