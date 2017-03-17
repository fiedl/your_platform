#
# A StatusGroup is a sub-Group of a Corporation that memberships model the
# current status of members within the corporation.
#
# At present time, the status of a user within a corporation is unique.
#
class StatusGroup < Group

  def assign_user(user, options = {})
    super(user, options).becomes(Memberships::Status)
  end

  def self.find_all_by_group(group)
    group.descendant_groups.where(type: "StatusGroup")
  end

  def self.find_by_user_and_corporation(user, corporation)
    status_groups = corporation.status_groups & user.status_groups

    # Send this error to our support address using the `ExceptionNotifier`
    # but continue to execute the code. Otherwise, the user interface
    # to fix the issue cannot be used.
    #
    begin
      raise "Status not unique for user #{user.id}. Please correct this. Found possible status groups: #{status_groups.map{ |x| x.name + ' (' + x.id.to_s + ')' }.join(', ') }." if status_groups.count > 1
    rescue => exception
      if Rails.env.test?
        Rails.logger.warn exception
      else
        ExceptionNotifier.notify_exeption(exception)
      end
    end

    status_groups.last
  end

end
