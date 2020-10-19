class Ability
  include CanCan::Ability

  def ability_classes
    [
      #Abilities::CorporationAbility,
      #Abilities::GroupAbility,
      #Abilities::UserAbility,
      #Abilities::UserAccountAbility,
      #Abilities::ProfileFieldAbility,
      #Abilities::DummyAbility
      Abilities::FreeGroupAbility,
      Abilities::PostAbility,
      Abilities::AttachmentAbility
    ]
  end

  # def initialize(user, options = {})
  #   ability_classes.each do |ability_class|
  #     self.merge ability_class.new(user, options.merge(parent_ability: self))
  #   end
  # end

  def initialize(user, options = {})
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # This is the new ability structure.
    # TODO: Migrate the other abilities to separated ability classes.
    #
    ability_classes.each do |ability_class|
      self.merge ability_class.new(user, options.merge(parent_ability: self))
    end

    # Attention: Check outside whether the user's role allowes that preview!
    # Currently, this is done in ApplicationController#current_ability.
    #
    @preview_as = options[:preview_as]
    @preview_as = nil if @preview_as.blank?

    # These roles do not make sense here and may block the `view_as?` method.
    @preview_as = nil if @preview_as.in? ['full_member']

    # There are two kinds of token: `User#token` and `AuthToken#token`,
    # which are both handled by the same parameter:
    @token = options[:token]
    @user_by_auth_token = options[:user_by_auth_token]

    @read_only_mode = options[:read_only_mode]
    @user = user || @user_by_auth_token

    # Fast lane
    can :read, Pages::PublicPage

    if @user.try(:account) # has to be able to sign in
      if @user_by_auth_token
        # The user is identified via auth token.
        # So, do not grant the regular rights but only
        # the rights granted by the token.
        rights_for_auth_token_users
      elsif user
        if user.has_flag? :dummy
          rights_for_dummy_users
        else
          if user.global_admin? and view_as?(:global_admin)
            rights_for_global_admins
          end
          if user.admin_of_anything? and view_as?(:admin)
            rights_for_local_admins
            rights_for_page_admins
          end
          if view_as?([:officer, :admin])
            rights_for_local_officers
          end
          if view_as?([:global_officer, :officer, :admin]) and user.is_global_officer?
            rights_for_global_officers
          end
          if user.developer?
            rights_for_developers
          end
          if user.beta_tester?
            rights_for_beta_testers
          end
          rights_for_signed_in_users
        end
      end
    end
    rights_for_everyone
    restrictions_for_everyone
  end

  def view_as?(role)
    (view_as.nil?) or (view_as.to_s == '') or if role.kind_of?(Array)
      view_as.in? role
    else
      view_as == role
    end
  end
  def view_as
    preview_as.try(:to_sym)
  end
  def preview_as
    @preview_as
  end
  def token
    @token
  end
  def auth_token
    @auth_token ||= AuthToken.where(token: token).first if @user_by_auth_token
  end
  def read_only_mode?
    @read_only_mode
  end
  def user
    @user
  end

  def rights_for_beta_testers
    # can :use, :new_menu_feature
    can :use, :tab_view  # this switch is only for user-tabs; group-tabs are for all.
    can :use, :merit
    can :use, :documents_index
    can :use, :nav_dropdowns
  end

  def rights_for_developers
    can :use, Rack::MiniProfiler

    can :use, :requests_index
    can :use, :permalinks
    can :use, :demo_mode

    can :use, :masquerade do
      # Only global admins that are developers are allowed
      # to masquerade as other users. This is used for debugging.
      user.global_admin?
    end
    can :masquerade_as, User do
      can? :use, :masquerade
    end
  end

  def rights_for_global_admins
    if read_only_mode?
      can :read, :all
      can :index, :all
    else
      can :manage, :all
      can :execute, [Workflow, WorkflowKit::Workflow]
      cannot :destroy, Group
    end

    # There are features for developers and beta testers.
    cannot :use, :all

    can :use, :demo_mode
    can :use, :corporation_couleur
    can :use, :dark_mode
  end

  def rights_for_local_admins
    # Achtung Wingolfsplattform: Überschreibt diese Methode derzeit!
    can :index, PublicActivity::Activity
    can :index, Issue
    if not read_only_mode?
      can :manage, Group do |group|
        group.admins_of_self_and_ancestors.include? user
      end

      can [:update, :change_first_name, :change_alias, :create_account_for, :change_status], User, id: Role.of(user).administrated_users.map(&:id)
      can :manage, UserAccount, user_id: Role.of(user).administrated_users.map(&:id)

      can :manage, ProfileField do |profile_field|
        profile_field.profileable.nil? ||  # in order to create profile fields
          can?(:update, profile_field.profileable)
      end

      can :execute, [Workflow, WorkflowKit::Workflow] do |workflow|
        # Local admins can execute workflows of groups they're admins of.
        # And they can execute the mark_as_deceased workflow, which is a global workflow.
        #
        (workflow.id == Workflow.find_mark_as_deceased_workflow_id) ||
        (workflow.admins_of_ancestors.include?(user))
      end
    end

    can :index, :home_pages
    can :create, Pages::HomePage
  end

  def rights_for_page_admins
    can :manage, Page do |page|
      user.administrated_objects.include? page
    end
    can :update, Event do |event|
      event.id.in? Page.where(id: user.page_ids_of_pages_the_user_is_officer_of).collect(&:event_ids).flatten
    end
  end

  def rights_for_local_officers
    can :export_member_list, Group do |group|
      user.in? group.officers_of_self_and_ancestors
    end

    if not read_only_mode?
      # Local officers can create events in their groups.
      #
      can :create, Event
      can [:create_event, :create_event_for], Group do |group|
        user.in? group.officers_of_self_and_ancestor_groups
      end
      can [:update, :destroy, :invite_to], Event do |event|
        event.group && user.in?(event.group.officers_of_self_and_ancestor_groups)
      end
      can :update, Group do |group|
        group.has_flag?(:contact_people) && can?(:update, group.parent_events.first)
      end
      can :export_calendar_feed_url_for_local_homepage, Group do |group|
        can? :update, group
      end

      can :update, SemesterCalendar do |semester_calendar|
        semester_calendar.group && user.in?(semester_calendar.group.officers_of_self_and_ancestor_groups)
      end
      can :create_attachment_for, SemesterCalendar do |semester_calendar|
        can? :update, semester_calendar
      end
      can :change_term, SemesterCalendar do |semester_calendar|
        can?(:update, semester_calendar)
      end
      can :create, SemesterCalendar
      can :destroy, SemesterCalendar do |semester_calendar|
        can? :update, semester_calendar
      end

      can :update_accommodations, Corporation do |corporation|
        user.in? corporation.officers
      end
      can :create_accommodation_sepa_debit, Corporation do |corporation|
        user.in? corporation.wohnheimsverein.officers if corporation.wohnheimsverein
      end

      # Local officers of pages can edit their pages and sub-pages
      # as long as they are the authors or the pages have *no* author.
      #
      can [:update, :destroy, :publish], Page do |page|
        can?(:read, page) and page.officers_of_self_and_ancestors.include?(user) and (page.author == user or page.author.nil?)
      end

      # Create, update and destroy Pages
      #
      can :create_page_for, [Group, Page] do |parent|
        parent.officers_of_self_and_ancestors.include?(user)
      end
      can [:update, :destroy, :publish], Page do |page|
        (page.author == user) && (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
      end

      # Create, update and destroy Attachments
      #
      can :create_attachment_for, Page do |page|
        (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
      end

      # Local officers of pages can add attachments to the page and subpages
      # and modify their own attachments.
      #
      can :create_attachment_for, Page do |page|
        can?(:read, page) and page.officers_of_self_and_ancestors.include?(user)
      end

    end
  end

  def rights_for_global_officers
    can :export_member_list, Group
    if not read_only_mode?
      can [:create_event, :create_event_for], Group
      can :create, Event
      can [:update, :destroy, :invite_to], Event do |event|
        event.contact_people.include? user
      end
    end
  end

  def rights_for_signed_in_users
    can :read, :terms_of_use
    can :accept, :terms_of_use if not read_only_mode?
    can :use, :single_sign_on

    can :index, :root

    can :index, :contacts
    can :index, :documents
    can :index, :my_groups
    can :index, :gesuche_und_angebote
    can :index, :calendars
    can :index, :heraldics
    can :index, SupportRequest

    can :index_mine, Group

    can :read, User, id: user.id
    can :index, User

    can :read, Corporation
    can :index_accommodations, Corporation

    # Regular users can access the list of mailing lists.
    #
    can :index, MailingList

    # Regular users can index officers.
    can :index, :officers

    if not read_only_mode?
      # Jeder muss Dokumente erstellen können, z.B. um Konventsprotokolle hochzuladen.
      # Ansonsten würden auch Verteilermails mit Dokumenten fehlschlagen.
      can :create, Document

      # Regular users can create, update or destroy own profile fields
      # that do not belong to the General section.
      #
      can [:create, :read, :update, :destroy], ProfileField do |field|
        field.profileable.nil? or # to allow creating fields
        ((field.profileable == user) and (field.type != 'ProfileFields::General') and (field.key != 'date_of_birth'))
      end

      # Regular users can update their personal title and academic degree.
      #
      can :update, ProfileField do |field|
        (field.profileable == user) and (field.key.in? ['personal_title', 'academic_degree', 'cognomen'])
      end

      # They can change their first name, but not their surname.
      #
      can [:update, :change_first_name, :change_alias], User, :id => user.id

      # They can change their password, i.e. modify their user account.
      #
      can :update, UserAccount, :user_id => user.id

      # Regular users can update their own validity ranges of memberships
      # in order to update their corporate vita.
      #
      can :update, Membership, :descendant_id => user.id

      # Everyone who can join an event, can add images to this event.
      # Then, he will automatically join the event.
      # Also, all contact people can add images.
      #
      can :create_attachment_for, Event do |event|
        can?(:join, event) or event.attendees.include?(user) or event.contact_people.include?(user)
      end

      # If a user is contact person of an event, he can provide pages and
      # attachment for this event.
      #
      # TODO: New role 'contact person'.
      #
      can [:update, :create_page_for], Event do |event|
        event.contact_people.include? user
      end
      can [:update, :create_attachment_for, :destroy, :publish], Page do |page|
        page.ancestor_events.map(&:contact_people).flatten.include? user
      end

      # If a user can read an object, he can comment it.
      #
      can [:create_comment_for, :create_comment], [Post] do |commentable|
        can? :read, commentable
      end

      # There are blogs where everyone can post.
      #
      can :create_page_for, Page do |page|
        page.settings.anyone_can_create_blog_posts && can?(:read, page)
      end
      can [:update, :destroy, :publish], Page do |page|
        page.parent.kind_of?(Page) && page.parent.settings.anyone_can_create_blog_posts && can?(:read, page) && (page.author == user)
      end

    end

    can :read, Group do |group|
      # Regular users cannot see the former_members_parent groups
      # and their descendant groups.
      #
      not (group.has_flag?(:former_members_parent) || group.ancestor_groups.find_all_by_flag(:former_members_parent).count > 0)
    end

    can :read, Page do |page|
      (page.group.nil? || page.group.members.include?(user)) && page.ancestor_users.none?
    end

    # All users can join events.
    #
    can :read, Event
    if not read_only_mode?
      can :join, Event
      can :leave, Event
    end
    can :index, Event
    can :index_events, Group
    can :index_events, User, :id => user.id

    can [:create_post, :create_post_for], Event, group_id: user.group_ids
    can [:create_post, :create_post_for], Event, parent_groups: { id: user.group_ids }

    # Name auto completion
    #
    can :autocomplete_title, User

    # All users can read their notifications.
    can :index, Notification
    can :read, Notification, recipient: {id: user.id}

    # Comments:
    # - Users can read comments for all objects they can read anyway.
    # - And they can create comments for these objects as well (see above.)
    can :read, Comment do |comment|
      can? :read, comment.commentable
    end

    # All signed-in users can read their news (timeline).
    can :index, :news

    # Read projects
    can [:read, :update], Project do |project|
      project.group.members.include? user
    end

    # Renew caches
    can :renew_cache, [User, Group, Page, Event] do |obj|
      can? :read, obj
    end

    # Betas
    # All users can see what betas we have.
    can :read, Beta
    can :index, Beta
    # Only beta members can create invitations.
    can :create_beta_invitation_for, Beta do |beta|
      beta.invitees.include? user
    end
  end

  def rights_for_auth_token_users
    p "===TOKEN #{auth_token.user} #{auth_token.resource}"
    if auth_token && Ability.new(auth_token.user).can?(:read, auth_token.resource)
      can :read, auth_token.resource

      if auth_token.resource.kind_of? Page
        auth_token.resource.attachments.each do |attachment|
          can [:read, :download], attachment
        end
      elsif auth_token.resource.kind_of? Event
        auth_token.resource.attachments.each do |attachment|
          can [:read, :download], attachment
        end
        # TODO  can post photos
      end
    end
  end

  def rights_for_everyone

    # Feature switches
    #
    can :use, :semester_calendars

    # can :use, :mail_delivery_account_filter
    can :use, :help_videos
    can :use, :permalinks

    # it's not ready, yet, but the tests use it already.
    if Rails.env.test?
      can :use, :wysihtml

      can :use, :blog_post_comments
      can :use, :mailing_lists
    end

    # Use the tabs view in users#show. This has been a beta feature previously.
    # TODO: Remove the feature switch whenever you feel we won't switch back.
    #
    can :use, :tab_view


    # Imprint
    # Make sure all users (even if not logged in) can read the imprint.
    #
    can :read, Page, Page.flagged(:imprint) do |page|
      # This block is to make sure that the scope scope worked.
      # FIXME: Make this block unnecessary.
      page.has_flag?(:imprint)
    end

    # All users can read the public website.
    #
    can :read, Page do |page|
      page.public?
    end

    # All users can read the public bios of the users.
    #
    can :read_public_bio, User

    # All users can comment contents they can read.
    #
    can :create_comment_for, BlogPost do |blog_post|
      can? :read, blog_post
    end

    # All users can read public events.
    #
    can :read, Event do |event|
      event.publish_on_global_website || event.publish_on_local_website
    end
    can :index_attendees, Event do |event|
      can? :join, event
    end

    # All users can read semester calendars.
    can :index_events, Group
    can :read, SemesterCalendar

    # Listing Events and iCalendar (ICS) Export:
    #
    # There are event lists on public websites and webcal feeds.
    # Therefore the user might not be logged in through a regular
    # session. Some public feeds can be seen by anyone. Other
    # feeds require an auth token.
    #
    if token.present?
      tokened_user = UserAccount.find_by_auth_token(token)
      if tokened_user
        can :index_events, Group
        can :index_events, User do |other_user|
          # To index the events relevant to a certain user,
          # one has to provide the correct auth token that corresponds
          # to that user.
          tokened_user == other_user.account
        end
        can :read, Event do |event|
          tokened_user.user.can? :read, event
        end
      end
    end
    can :index_public_events, :all

    # RSS Feeds
    can :index, :feeds
    can :read, :default_feed
    can :read, :public_feed
    if token.present? # && tokened_user = UserAccount.find_by_auth_token(token).try(:user)
      can :read, :personal_feed
    end

    # All users can show tags. This does not mean that they
    # can see all tagged contents though.
    can :read, ActsAsTaggableOn::Tag

    # Activate platform mailgate, i.e. accept incoming email.
    # The authorization to send to a specific group is done separately in
    # the StoreMailAsPostsAndSendGroupMailJob.
    #
    can :use, :platform_mailgate

    # All users can use the blue help button.
    #
    can :create, :support_request

    # All users can use the contact form.
    #
    can :create, ContactMessage

    # All users can load avatar images, since this is an api.
    # See AvatarsController.
    #
    can :read, :avatars

  end

  # During App-Store approval, we must give a dummy user access to our platform.
  # But he should not be able to access any real data.
  #
  def rights_for_dummy_users
    can :read, :terms_of_use
    can :accept, :terms_of_use if not read_only_mode?

    can :read, User do |user|  # Only read other dummy users.
      user.has_flag? :dummy
    end

    can :read, Corporation do |corporation|
      corporation.active?
    end

    can :index, Event
    can :index, User
    can :index, Corporation

    can :read, Page do |page|
      page.has_flag? :songs
    end

    can [:read, :download], Attachment do |document|
      document.has_flag? :dummy
    end
  end

  def restrictions_for_everyone
    cannot :use, :pdf_search  # It's not ready, yet. https://trello.com/c/aYtvpSij/1057

    # Nobody can destroy non-empty pages that are older than 10 minutes.
    # Pages that are no longer needed can be archived instead.
    # Public pages can be destroyed until TODO we have the archive-pages interface back.
    #
    cannot :destroy, Page do |page|
      (page.created_at < 10.minutes.ago) && page.not_empty? && !page.kind_of?(Pages::PublicPage)
    end

    # Nobody can destroy events with attendees.
    # If an event is cancelled, it should be noted in the event title.
    # Otherwise, the event would just be missing in the users' calendars.
    #
    cannot :destroy, Event do |event|
      event.attendees.count > 0
    end

    # Nobody can destroy semester calendars with attachments.
    #
    cannot :destroy, SemesterCalendar do |semester_calendar|
      semester_calendar.attachments.count > 0
    end

    # Nobody can destroy or update a ballot that is signed.
    cannot [:update, :destroy, :submit, :create_attachment_for], DecisionMaking::Ballot do |ballot|
      ballot.signed?
    end

    # We don't want people to re-use older semester calendars. Thus, after a while,
    # the term cannot be changed anymore. They should create new calendars for new
    # terms.
    cannot :change_term, SemesterCalendar do |semester_calendar|
      semester_calendar.created_at < 1.day.ago
    end

    # Nobody can recalculate term reports that have already been submitted.
    cannot :recalculate, TermReport do |term_report|
      term_report.state && !(term_report.state.rejected?)
    end
  end

end