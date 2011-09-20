# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
# 
#   <% if logged_in? %>
#     Welcome <%=h current_user.username %>! Not you?
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
# 
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
# 
#   before_filter :login_required, :except => [:index, :show]
module Notification
  def self.included(controller)
    controller.send :helper_method, :send_notifications
    # controller.filter_parameter_logging :password
  end


  def send_notifications(opt={})

    logger.info ''
    logger.info '--------------------------------------------------------------------[ inside send_notifications ]---'
    logger.info "event = #{opt[:event]}"
    logger.info "users = #{opt[:user_ids].inspect}"

    data = opt[:data]
    case opt[:event]
    when :sr_escalated
      sr = data[:service_request]
      message = "SR ##{sr.sr_number} just got escalated to #{sr.severity_display} / #{sr.escalation_display}"
      logger.info "message = #{message}"

      subscriptions = Subscription.for_watchers(opt[:user_ids])

      logger.info "subscriptions = #{subscriptions.inspect}"
      # find(:all, # TODO should handle multiple devices
      # :conditions => ["user_id=? and sr_severity>=?", self.watchers.collect(&:owner_id), severity])

      subscriptions.each do |subscription|
        # subscription = subscription.first
        case subscription.notification_method.to_sym
        when :c2dm
          logger.info "@@@@@@@@@@@@@@@ creating C2DM notification for #{subscription.user.fullname}"
          devices = C2dm::Device.find(:all, :conditions => ["registration_id=?", subscription.display_id])
          if devices.empty?
            devices = [C2dm::Device.create(:registration_id => subscription.display_id)]
          end

          unless devices.empty?
            devices.each do |device|
              notification = { :device=>device, :collapse_key=>"emc_support", 
                :delay_while_idle => true, 
                :data => {"badge" => "0", "sound" => 'startrek_escalation', 
                  "message" => message, "event" => 'sr_escalated', "sr_number" => sr.sr_number.to_s
                }
              }
              logger.info "C2dm::Notification created with #{notification.inspect}"
              C2dm::Notification.create notification
            end
          end
        when :apn
          logger.info "@@@@@@@@@@@@@@@ creating APN notification for #{subscription.user.fullname}"
          devices = APN::Device.find(:all, :conditions => ["token=?", subscription.display_id])
          if devices.empty?
            app = APN::App.first ## TODO should look up be name
            if app
              devices = [APN::Device.create(:token => subscription.display_id,:app => app)]
            end
          end

          unless devices.empty?
            devices.each do |device|
              notification = {:device => device, 
                :badge => 0,
                :sound => 'startrek_escalation.caf', 
                :alert => message,
                :custom_properties => {:sr_number => sr.sr_number, :event => 'sr_escalated'}
              }
              logger.info "notify_owner with  #{notification.inspect}"
              APN::Notification.create notification
            end
          end
        else
          logger.info "Notification method #{subscription.notification_method} is not supported"
          subscription.destroy
        end
      end





    when :sr_note_added
      # sr_number
      # note id
      # note body
      logger.info "Note added to SR #{opt[:service_request].inspect}"
      note = data[:note]
      sr = note.service_request
      # message = "SR ##{sr.sr_number}: #{note.clean_body[0..92]}"
      message = "SR ##{sr.sr_number}: You have a new note!"
      logger.info "message = #{message}"

      subscriptions = Subscription.for_watchers(opt[:user_ids])

      logger.info "subscriptions = #{subscriptions.inspect}"
      # find(:all, # TODO should handle multiple devices
      # :conditions => ["user_id=? and sr_severity>=?", self.watchers.collect(&:owner_id), severity])

      subscriptions.each do |subscription|
        # subscription = subscription.first
        case subscription.notification_method.to_sym
        when :c2dm
          logger.info "@@@@@@@@@@@@@@@ creating C2DM notification for #{subscription.user.fullname}"
          devices = C2dm::Device.find(:all, :conditions => ["registration_id=?", subscription.display_id])
          if devices.empty?
            devices = [C2dm::Device.create(:registration_id => subscription.display_id)]
          end

          unless devices.empty?
            devices.each do |device|
              notification = { :device=>device, :collapse_key=>"emc_support", 
                :delay_while_idle => true, 
                :data => {"badge" => "0", "sound" => 'startrek_new-note', 
                  "message" => message, "event" => 'sr_note_added', "sr_number" => sr.sr_number.to_s
                }
              }
              logger.info "C2dm::Notification created with #{notification.inspect}"
              C2dm::Notification.create notification
            end
          end
        when :apn
          logger.info "@@@@@@@@@@@@@@@ creating APN notification for #{subscription.user.fullname}"
          devices = APN::Device.find(:all, :conditions => ["token=?", subscription.display_id])
          if devices.empty?
            app = APN::App.first ## TODO should look up be name
            if app
              devices = [APN::Device.create(:token => subscription.display_id,:app => app)]
            end
          end

          unless devices.empty?
            devices.each do |device|
              notification = {:device => device, 
                :badge => 0,
                :sound => 'startrek_new-note.caf', 
                :alert => message,
                :custom_properties => {:sr_number => sr.sr_number, :event => 'sr_note_added'}
              }
              logger.info "notify_owner with  #{notification.inspect}"
              APN::Notification.create notification
            end
          end
        else
          logger.info "Notification method #{subscription.notification_method} is not supported"
          subscription.destroy
        end
      end
    end
    return

  end



  private

end
