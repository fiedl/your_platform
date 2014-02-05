namespace :identify do
  
  task :duplicate_users => [:environment] do

    require 'importers/models/log'
    $log = Log.new
    
    $log.head "Wingolfsplattform: Identify duplicate users"
    
    $log.section "Criteria"
    $log.info    "  * first and last name"
    $log.info    "  * date of birth"

    $log.section "Duplicate Users"
    identified_duplicates = []
    for user in User.all
      unless user.in? identified_duplicates
        for duplicate_user in possible_duplicates_of user
          $log.warning "  * The users #{user.title} (#{user.w_nummer}) and #{duplicate_user.title} (#{duplicate_user.w_nummer}) might be duplicates."
          identified_duplicates << duplicate_user
        end
      end
    end

    $log.info ""
    $log.info "Finished."

  end

  # Helper Methods
  # ===========================================================
  
  def possible_duplicates_of(user)
    User
    .where(first_name: user.first_name, last_name: user.last_name)
    .where('id != ?', user.id)
    .select { |duplicate_user| duplicate_user.date_of_birth == user.date_of_birth }
  end
  
end

