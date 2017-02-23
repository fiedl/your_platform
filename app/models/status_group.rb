#
# A StatusGroup is a sub-Group of a Corporation that memberships model the
# current status of members within the corporation.
#
# At present time, the status of a user within a corporation is unique.
#
class StatusGroup < Group

  def self.find_all_by_corporation(corporation)
    self.find_all_by_group(corporation)
  end

  def self.find_all_by_group(group)
    group.leaf_groups.select do |leaf_group|
      leaf_group.ancestor_events.count == 0
    end
  end

  def self.find_all_by_user(user, options = {})
    user_groups = options[:with_invalid] ? user.parent_groups : user.direct_groups
    user.corporations.collect do |corporation|
      StatusGroup.find_all_by_corporation(corporation)
    end.flatten & user_groups
  end

  def self.find_by_user_and_corporation(user, corporation)
    status_groups = (StatusGroup.find_all_by_corporation(corporation) & StatusGroup.find_all_by_user(user))

    # Send this error to our support address using the `ExceptionNotifier`
    # but continue to execute the code. Otherwise, the user interface
    # to fix the issue cannot be used.
    #
    begin
      raise "Status not unique for user #{user.id}. Please correct this. Found possible status groups: #{status_groups.map{ |x| x.name + ' (' + x.id.to_s + ')' }.join(', ') }." if status_groups.count > 1
    rescue => exception
      ExceptionNotifier.notify_exeption(exception)
    end

    status_groups.last
  end

end
