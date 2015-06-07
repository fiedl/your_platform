namespace :your_platform do
  namespace :notifications do
    
    task :process => [:environment] do
      Time.use_zone("Berlin") do
        process_notifications
      end
    end
    
    task :worker => [:environment] do
      Time.use_zone("Berlin") do
        loop_process_notifications interval: 60.seconds
      end
    end
    
    def loop_process_notifications(options = {interval: 60.seconds})
      notifications_log "== STARTING NOTIFICATIONS TASK LOOP =="
      notifications_log "   with an interval of #{options[:interval].to_s} seconds."
      detect_environment
      while(true) do
        process_notifications
        sleep options[:interval]
      end
    end
    
    def process_notifications
      notifications_log "== Processing #{Notification.due.count} notifications =="
      if production_stage_or_development_environment?
        notifications = Notification.due.deliver
        notifications.each do |notification|
          notifications_log "   -> id=#{notification.id}: #{notification.recipient.title} <#{notification.recipient.email}>"
        end
      end
      notifications_log "   Done."
    end
    
    def production_stage_or_development_environment?
      if @production_stage_or_development_environment
        return true
      else
        notifications_log "   [Skipped due to staging environment.]" if Notification.due.count > 0
        return false
      end
    end
    
    def detect_environment
      notifications_log "   Environment: #{Rails.env.to_s}, Stage: #{::STAGE}"
      @production_stage_or_development_environment = true if Rails.env.development? or Rails.env.production?
    end
    
    def notifications_log(text)
      notifications_worker_log.info text
      print "#{I18n.localize(Time.zone.now)}  #{text}\n"
    end
    
    def notifications_worker_log
      @notifications_worker_notifications_log ||= Logger.new("#{Rails.root}/log/your_platform_notifications.log")
    end
  end
end