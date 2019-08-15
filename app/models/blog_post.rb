class BlogPost < Page
  include Commentable

  include HostAndGuestGroups

  def self.relevant_to(user)
    # TODO: Replace this with proper graph query
    group_ids_the_user_is_no_member_of = Group.pluck(:id) - user.group_ids
    pages_that_belong_to_groups_the_user_is_no_member_of = Page
      .includes(:ancestor_groups)
      .where(groups: {id: group_ids_the_user_is_no_member_of})
    return where.not(id: (pages_that_belong_to_groups_the_user_is_no_member_of + [0])) # +[0]-hack: otherwise the list is empty when all pages should be shown, i.e. for fresh systems.
  end

  def as_json(*args)
    super.merge({
      youtube: teaser_youtube_url
    })
  end

end
