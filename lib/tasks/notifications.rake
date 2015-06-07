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
      print "== #{I18n.localize(Time.zone.now)} == STARTING NOTIFICATIONS TASK LOOP ==\n"
      print "   with an interval of #{options[:interval].to_s} seconds.\n"
      detect_environment
      while(true) do
        process_notifications
        sleep options[:interval]
      end
    end
    
    def process_notifications
      print "== #{I18n.localize(Time.zone.now)} == Processing #{Notification.due.count} notifications ==\n"
      if production_stage_or_development_environment?
        notifications = Notification.due.deliver
        notifications.each do |notification|
          print "   -> id=#{notification.id}: #{notification.recipient.title} <#{notification.recipient.email}>\n"
        end
      end
      print "   #{I18n.localize(Time.zone.now)} -- Done.\n"
    end
    
    def production_stage_or_development_environment?
      if @production_stage_or_development_environment
        return true
      else
        print "   [Skipped due to staging environment.]" if Notification.due.count > 0
        return false
      end
    end
    
    def detect_environment
      print "   Environment: #{Rails.env.to_s}, Stage: #{::STAGE}\n"
      @production_stage_or_development_environment = true if Rails.env.development? or ::STAGE == "wingolfsplattform" # wingolfsplattform-master, wingolfsplattform-sandbox
    end
  end
end