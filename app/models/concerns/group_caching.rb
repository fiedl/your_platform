concern :GroupCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise, the methods to be cached are not declared, yet.
  #
  included do
    after_save { self.delay.renew_cache }

    cache :corporation_id
    cache :leaf_groups

    cache :group_of_groups?
    cache :name_with_corporation
  end

  def fill_cache
    super
    ancestor_groups(true).each { |g| g.leaf_groups } # TODO: WHAT IF WE CACHE LEAF_GROUP_IDS. DO WE NEED THIS LOOP THEN AS THE LEAFS ATTRIBUTES WOULD NOT BE CACHED?
  end

  include StructureableRoleCaching
end