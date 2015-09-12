#
# In this project, user group memberships do not neccessarily last forever.
# They can begin at some time and end at some time. This is expressed by the
# ValidityRange of a membership.
#
#
# ## Examples
#
#     membership.valid_from  # =>  time
#     membership.valid_to    # =>  time
#     membership.invalidate
#
# 
# ## Scopes
# 
#   The same functionality can be described from tho different perspectives:
# 
#   From the "validity perspective", a membership can be currently valid or
#   invalid. One can filter memberships by their validity status.
#   
#   From the "time perspective", there are current memberships and past
#   memberships. 
#   
#   These perspectives are linked by the fact that "past memberships" are just
#   memberships that are currently invalid but have been valid in the past.
#   
#   Validity Perspective:    
#   
#       UserGroupMembership.valid
#       UserGroupMembership.invalid
#       UserGroupMembership.with_invalid
#   
#   Time Perspective: 
# 
#       UserGroupMembership.now
#       UserGroupMembership.past
#       UserGroupMembership.now_and_past
#       UserGroupMembership.now_and_in_the_past
#       UserGroupMembership.at_time(time)
#   
#   Default Scope: 
#
#   By default, the `valid` scope is applied, i.e. only memberships are 
#   found that are valid at present time. To override this scope, use the
#   either `with_invalid` scope.
#
# 
# ## Caveats
# 
#   * There is only one `valid_from` and one `valid_to` time per object. 
#     Therefore, you can't keep track of first invalidating an object and 
#     later re-validating it. Re-validating an object loses the information
#     of first invalidating it.
# 
#   * Currently, the future is not handled (`Article.future` and 
#     `article.invalidate at: 1.hour.from.now` do not work.) But this is 
#     planned to be implemented in the future.
# 
#   * Some functionality has been extracted out into the temporal_scopes gem 
#     in order to test the scopes easily. But, this code has been abandoned 
#     since the Rails-4 migration took more time.
#     => https://github.com/fiedl/temporal_scopes/blob/master/lib/temporal_scopes/has_temporal_scopes.rb
# 
#   * Rails 5 supports an `.or(...)` syntax: 
#     https://github.com/rails/rails/pull/16052
#     TODO: Refactor the queries in the scopes when migrating to Rails 5.
#
module UserGroupMembershipMixins::ValidityRange
  extend ActiveSupport::Concern
  
  #
  # This has been moved to DagLinkValidityRange.
  #
  
end

class Array
  def started_after(time)
    self.select { |membership| membership.valid_from && membership.valid_from >= time }
  end
end