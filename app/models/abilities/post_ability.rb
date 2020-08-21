class Abilities::PostAbility < Abilities::BaseAbility

  def rights_for_everyone
    can :read, Post, parent_pages: { type: ["Pages::PublicPage", "Pages::PublicGalleryPage", "Pages::PublicEventsPage"] }
    can :read, Post, publish_on_public_website: true
  end

  def rights_for_signed_in_users
    can :read, Post, ancestor_groups: { id: user.group_ids }
    can :read, Post, parent_events: { group_id: user.group_ids }
    can :read, Post, group: {id: user.group_ids}
    can :index_posts, Group, id: user.group_ids
    can :index_posts, User, id: user.id

    # Users can always read posts they have created, e.g.
    # - if they have left the group later
    # - if they have addressed another group
    #
    can :read, Post, author_user_id: user.id

    if not read_only_mode?
      can :create, Post

      can :update, Post, author_user_id: user.id, sent_at: nil, published_at: nil
      can :update_public_website_publication, Post, author_user_id: user.id

      # Force instant delivery after creating the post.
      #
      can :deliver, Post do |post|
        post.author == user and
        can? :force_post_notification, post.group
      end

      # Send messages to a group, either via web ui or via email:
      # This is allowed if the user matches the mailing-list-sender-filter setting.
      # Definition in: concerns/group_mailing_lists.rb
      #
      can [:create_post, :create_post_for, :create_post_via_email, :force_post_notification], Group do |group|
        group.user_matches_mailing_list_sender_filter?(user)
      end
    end
  end

  def rights_for_local_officers
    if not read_only_mode?
      # Global officers can post to any group.
      can [:create_post, :create_post_for, :create_post_via_email, :force_post_notification], Group
    end
  end

  def rights_for_local_admins
    can :update_public_website_publication, Post, ancestor_group_ids: user.administrated_group_ids
    can :update_public_website_publication, Post, parent_events: { parent_group_ids: user.administrated_group_ids }
    can :update_public_website_publication, Post, parent_events: { group_id: user.administrated_group_ids }
  end

  def rights_for_global_admins
  end
end