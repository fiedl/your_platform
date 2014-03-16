# 
# Dieses Skript dient der sukzessiven Freischaltung von Benutzer-Accounts ab dem 15.2.2014.
# 
# In einem Cron-Job soll dieses Skript minütlich ausgeführt werden, wobei dadurch
# minütlich ein Benutzer freigeschaltet wird und seine Willkommens-E-Mail erhält.
# Auf diese Weise sollten alle Benutzer nach drei Tagen freigeschaltet sein.
#
#
# ## Cron
#
# In cron:    
#   cd /var/wingolfsplattform && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake activate:random_account >> /var/wingolfsplattform/log/account_activation.log 2>&1
#
# Der Cron-Job kann deaktiviert werden, sobald das System die Abbruchs-E-Mail versandt hat,
# d.h. nun alle Benutzer-Accounts aktiviert sind.
#
#
# ## Stages
#
# Damit nicht versehentlich vorzeitig Benutzer-Accounts freigeschaltet werden, 
# während noch die Skripte eingerichtet werden, agiert dieser Task unterschiedlich
# in verschiedenen Stages, wobei die Stage durch einen Datei-Inhalt definiert ist.
#
#  /Stage 0 Idle Mode/    Es passiert nichts. (Voreinstellung)
#                         In diesem Stadium sollen keine Accounts freigeschaltet werden.
#               
#  /Stage 1 Test Mode/    Test-Stadium.
#                         In diesem Stadium soll sich alles so verhalten wie im Ernstfall, 
#                         nur dass die Accounts **nicht freigeschaltet** werden.
#
#  /Stage 2 Armed Mode/   Scharfgeschaltet.
#                         In diesem Stadium werden die Accounts tatsächlich freigeschaltet,
#                         sobald der Trigger ausgelöst wurde.
#
#                         Sobald alle Accounts freigeschaltet wurden, kehrt das System
#                         automatisch zu /Stage 0 Idle Mode/ zurück.
#
# Die aktuelle Stage, in der sich das System befindet, wird durch den Inhalt der Datei
# `tmp/account_activation.stage` festgelegt.
#
#
# ## Trigger
#
# Der rote Startknopf, der bei der Live-Schaltung gedrückt wird, löst den Trigger aus.
# Ab Auslösen des Triggers wird minütlich ein Benutzer herausgesucht, 
# das Live-Event-Display aktualisiert und, sofern sich das System in /Stage 2 Armed Mode/
# befindet, der Benutzer-Account tatsächlich freigeschaltet.
#
# Der Trigger-Zustand wird durch die Anwesenheit der Datei
# `tmp/account_activation.trigger` festgelegt. 
#
# Um den Trigger auszulösen, muss diese Datei erstellt werden. 
# Sobald die Trigger-Datei gelöscht wird, werden keine Accounts mehr aktiviert.
#
# 
# ## Zusammenfassung
#
# Damit die Benutzer-Accounts freigeschaltet werden, müssen also drei Bedingungen 
# erfüllt sein:
#
#   1. Der Cron-Job muss eingerichtet sein, der diesen Task minütlich auslöst.
#   2. Die Datei `wingolfsplattform/tmp/account_activation.stage` muss den Inhalt 
#      `/Stage 2 Armed Mode/` haben.
#   3. Die Datei `wingolfsplattform/tmp/account_activation.trigger` muss existieren.
#

namespace :activate do
  task :random_account => [:environment] do
    
    require 'importers/models/log'
    log = Log.new
    log.section 'Task: Activate random user account'
    log.info "Time:              #{I18n.localize Time.zone.now}"
    log.info "Trigger Status:    #{trigger_pressed?}"
    log.info "System Stage:      #{system_stage}"
    
    
    # Es wird nichts unternommen, solange der Trigger nicht gedrückt ist.
    #
    unless trigger_pressed?
      log.warning 'Trigger not pressed, yet. The file tmp/account_activation.trigger does not exist.'
      exit 0
    end
    
    # Es wird auch nichts unternommen, solange sich das System nicht im scharfen Zustand
    # oder zumindest im Test-Zustand befindet.
    #
    if not system_stage.in? ["/Stage 1 Test Mode/", "/Stage 2 Armed Mode/"]
      log.warning 'The system is currently in /Stage 0 Idle Mode/. You have to arm it first.'
      exit 0
    end
    
    # Zufälligen Benutzer heraussuchen
    #
    user = find_appropriate_random_user

    # Wenn es keinen Benutzer mehr gibt, der einen Account braucht, ist nichts zu tun.
    # Sonst den Account des Benutzers aktivieren.
    #
    if not user
      log.warning 'No account left that needs activation. Exit 1.'
      log.info "Going back to /Stage 0 Idle Mode/."
      switch_back_to_stage_zero
      exit 1  # exit status 1 so that cron will report this via email.
    else
      
      log.info "User:              #{user.title} (#{user.w_nummer})"
      
      # Aktuellen Benutzer in das Live-Event-Display schreiben.
      #
      if system_stage.in? ["/Stage 1 Test Mode/", "/Stage 2 Armed Mode/"]
        set_event_display user.title
      end
      
      # Wenn das System scharf ist, den Benutzer wirklich freischalten.
      #
      if system_stage == "/Stage 2 Armed Mode/"
        account_id = nil
        
        # ======= DANGER ZONE ========
        user.activate_account
        user.account.send_new_password
        account_id = user.account.id
        # ============================
        
        if account_id
          log.success "Account activated: #{account_id}"
        else
          log.error "Account activation failed."
          p user.errors
          p user.account.try(:errors)
          exit 1
        end
        
      end
      
    end
  end
  
  def find_appropriate_random_user
    $blacklisted_users = []
    read_blacklisted_users_from_cache
    until ($blacklisted_users.uniq.count == find_all_users_without_account.count) do
      user = find_random_user_without_account
      if not user.in? $blacklisted_users
        if user_is_appropriate?(user)
          return user 
        else
          $blacklisted_users << user
        end
      end
    end
    write_blacklisted_users_to_cache
  end

  def find_random_user
    User.order('RAND()').limit(1).first
  end
  
  def find_random_user_without_account
    find_all_users_without_account.order('RAND()').limit(1).first
  end
  
  def find_all_users_without_account
    User.includes(:account).where(:user_accounts => { :user_id => nil })
  end
  
  def user_is_appropriate?(user)
    user.present? and
    user.has_no_account? and 
    user.wingolfit? and 
    user.alive? and
    user.email.present?
  end
  
  def system_stage
    filename = File.join(Rails.root, 'tmp', 'account_activation.stage')
    if File.exists? filename
      stage = File.read(filename).gsub("\n", "").strip
    else
      stage = nil
    end
    stage = "/Stage 0 Idle Mode/" unless stage.present?
    return stage
  end
  
  def switch_back_to_stage_zero
    filename = File.join(Rails.root, 'tmp', 'account_activation.stage')
    if File.exists? filename
      File.delete filename
    end
  end
  
  def trigger_pressed?
    File.exists? File.join(Rails.root, 'tmp', 'account_activation.trigger')
  end
  
  def set_event_display(text)
    filename = File.join(Rails.root, 'tmp', 'live_event.txt')
    File.open(filename, 'w') { |file| file.write(text) }
  end
  
  def read_blacklisted_users_from_cache
    $blacklisted_users = Rails.cache.fetch(["account_activation_blacklist"]) { $blacklisted_users || [] }
  end
  def write_blacklisted_users_to_cache
    Rails.cache.write("account_activation_blacklist", $blacklisted_users)
  end

end