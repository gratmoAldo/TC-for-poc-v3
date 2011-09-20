class InboxSr < ActiveRecord::Base
  belongs_to :inbox
  belongs_to :service_request
end
