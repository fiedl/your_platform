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
#       Membership.valid
#       Membership.invalid
#       Membership.with_invalid
#   
#   Time Perspective: 
# 
#       Membership.now
#       Membership.past
#       Membership.now_and_past
#       Membership.now_and_in_the_past
#       Membership.at_time(time)
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
#     Therefore, when a user leaves and re-joins a group, this is represented
#     by two separate Membership objects.
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
concern :MembershipCollectionValidityRange do
  
  concerning :ValidityPerspective do
    def valid
      @valid = true
      return self
    end
    
    def invalid
      @invalid = true
      return self
    end
    
    def with_invalid
      @with_invalid = true
      return self
    end
  end
  
  concerning :TimePerspective do
    def now
      @now = true
      return self
    end
    
    def past
      @past = true
      return self
    end
    
    def in_the_past
      @past = true
      return self
    end
      
    def with_past
      @with_past = true
      return self
    end
      
    def now_and_past
      @now_and_in_the_past = true
      return self
    end
      
    def now_and_in_the_past
      @now_and_in_the_past = true
      return self
    end
      
    def at_time(time)
      @at_time = time
      return self
    end
      
    def this_year
      @this_year = true
      return self
    end
      
    def started_after(time)
      @started_after = time
      return self
    end
  end
  
  private
  
  def dag_links_for(attrs = {})
    links = DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true)
    links = links.where(descendant_id: attrs[:user].id) if attrs[:user]
    links = links.where(ancestor_id: attrs[:group].id) if attrs[:group]
    links = links.where(descendant_id: attrs[:user_ids]) if attrs[:user_ids]
    links = links.where(ancestor_id: attrs[:group_ids]) if attrs[:group_ids]
    
    unless attrs[:ignore_validity_range_filters]
      # Validity Perspective
      #
      links = links.valid if @valid
      links = links.invalid if @invalid
      links = links.with_invalid if @with_invalid
      
      # Time Perspective
      #
      links = links.now if @now
      links = links.past if @past
      links = links.with_past if @with_past
      links = links.now_and_in_the_past if @now_and_in_the_past
      links = links.at_time(@at_time) if @at_time
      links = links.this_year if @this_year
      links = links.started_after(@started_after) if @started_after
    end
    unless attrs[:no_eager_loading]
      # Include the associated objects to avoid the N+1 problem.
      #
      links = links.includes(:ancestor, :descendant)
    end

    return links
  end
  
end