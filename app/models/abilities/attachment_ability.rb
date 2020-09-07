class Abilities::AttachmentAbility < Abilities::BaseAbility

  def rights_for_everyone
    can [:read, :download], Attachment, title: ['avatar', 'avatar_background']
    can [:read, :download], Attachment do |attachment|
      attachment.id.in?(Attachment.logos.pluck(:id))
    end
    can [:read, :download], Attachment, parent_type: "Page", parent: { type: ["Pages::PublicPage", "Pages::PublicGalleryPage", "Pages::PublicEventsPage"] }
    can [:read, :download], Attachment, parent_type: "SemesterCalendar"
    can [:read, :download], Attachment, parent_type: "Post", parent: { parent_pages: { type: ["Pages::PublicPage", "Pages::PublicGalleryPage", "Pages::PublicEventsPage"] } }
    can [:read, :download], Attachment, parent_type: "Post", parent: { publish_on_public_website: true }

    can [:read, :download], Attachment do |attachment|
      attachment.parent.kind_of?(Page) && attachment.parent.public?
    end

    # Thumbnails should not add delay. They do not contain
    # valueable information. Just pass them through.
    can :download_thumb, Attachment
  end

  def rights_for_signed_in_users
    can [:read, :download], Attachment, parent_type: "Group", parent_id: user.group_ids
    can [:read, :download], Attachment, Attachment.belongs_to_page_without_group do |attachment|
      attachment.parent_page && attachment.parent_page.ancestor_groups.none?
    end

    # Post attachments can be read if the post can be read.
    can [:read, :download], Attachment do |attachment|
      attachment.parent.kind_of?(Post) and parent_ability_can?(:read, attachment.parent)
    end

    if not read_only_mode?
      can [:update, :destroy], Attachment, author_user_id: user.id

      # If a user is contact person of an event, he can provide pages and
      # attachment for this event.
      #
      can [:update, :destroy], Attachment do |attachment|
        attachment.author == user and
        attachment.parent.kind_of?(Page) and
        attachment.parent.ancestor_events.map(&:contact_people).flatten.include?(user)
      end
    end
  end

  def rights_for_page_admins
    can :manage, Attachment do |attachment|
      parent_ability_can? :manage, attachment.parent
    end
  end

  def rights_for_local_officers
    if not read_only_mode?
      can :update, Attachment do |attachment|
        parent_ability_can?(:read, attachment) &&
        (attachment.parent.respond_to?(:group) && attachment.parent.group) && (attachment.parent.group.officers_of_self_and_ancestors.include?(user)) &&
        ((attachment.author == user) || (attachment.parent.respond_to?(:author) && attachment.parent.author == user))
      end

      # Local officers of pages can add attachments to the page and subpages
      # and modify their own attachments.
      #
      can [:update, :destroy], Attachment do |attachment|
        parent_ability_can?(:read, attachment.parent) and
        parent_ability_can?(:read, attachment) and
        attachment.author == user
      end

      # Local officers can also modify any attachment of their own pages
      # in order to review their own pages.
      #
      can [:update, :destroy], Attachment do |attachment|
        attachment.parent.respond_to?(:officers_of_self_and_ancestors) &&
        attachment.parent.officers_of_self_and_ancestors.include?(user) &&
        parent_ability_can?(:read, attachment) &&
        (attachment.parent.respond_to?(:author) && attachment.parent.author == user)
      end
    end
  end

end
