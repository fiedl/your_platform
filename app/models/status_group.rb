
# This extends the your_platform StatusGroup model.
require_dependency YourPlatform::Engine.root.join( 'app/models/status_group' ).to_s

class StatusGroup

  # List all status groups of a Corporation.
  #
  # In addition to the selection in YourPlatform, the special status groups
  # Stifter, Neustifter have to be excluded, since these status membersips
  # are additional to other simultaneous status memberships.
  #
  # `orig_find_all_by_corporation` represents the method `find_all_by_corporation`
  # in YourPlatform.
  #
  self.singleton_class.send :alias_method, :orig_find_all_by_corporation, :find_all_by_corporation
  def self.find_all_by_corporation(corporation)
    orig_find_all_by_corporation(corporation).select do |group|
      not group.name.in? ["Stifter", "Neustifter"]
    end
  end

end
