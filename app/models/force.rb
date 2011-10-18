class Force < ActiveRecord::Base
  validates_presence_of   :authorization,
                          :allow_nil => false,
                          :message => "must be valid"
  validates_presence_of   :serverBase,
                          :allow_nil => false,
                          :message => "must be valid"
  
end
