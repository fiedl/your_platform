class Group < ApplicationRecord

  has_dag_links ancestor_class_names: %w(Group Page Event), descendant_class_names: %w(Group User Page Workflow Project), link_class_name: 'DagLink'

  default_scope { includes(:flags) }
  scope :regular, -> { not_flagged([:contact_people, :attendees, :officers_parent, :group_of_groups, :everyone, :corporations_parent]) }
  scope :has_descendant_users, -> { includes(:descendant_users).where(users: { id: nil }) }

  include Structureable
  include GroupGraph
  include Navable
  include GroupMemberships
  include GroupMemberList
  include GroupEveryone
  include GroupMixins::Corporations
  include GroupMixins::Roles
  include GroupMixins::Guests
  include GroupMixins::HiddenUsers
  include GroupMixins::Developers
  include GroupMixins::Officers
  include GroupMixins::Import
  include GroupPosts
  include GroupAttachments
  include GroupProfile
  include GroupMailingLists
  include GroupDummyUsers
  include GroupWelcomeMessage
  include GroupSemesterCalendars
  include GroupEvents
  include GroupListExports
  include GroupMapItem
  include HasProfile
  include GroupSearch
  include GroupAvatar
  include GroupCharts
  include GroupPublicWebsite

  # Easy group settings: https://github.com/huacnlee/rails-settings-cached
  # For example:
  #
  #     group = Group.find(123)
  #     group.settings.color = :red
  #     group.settings.color  # =>  :red
  #
  include RailsSettings::Extend



  after_create     :import_default_group_structure  # from GroupMixins::Import

  # General Properties
  # ==========================================================================================

  # The title of the group, i.e. a kind of caption, e.g. used in the <title> tag of the
  # webpage. By default, this returns just the name of the group. But this may be changed
  # in the main application.
  #
  def title
    self.name
  end

  # The name of the group.
  # If there is a translation for that group name, e.g. for a generic group name like
  # 'admins', use the translation.
  #
  def name
    I18n.t( super.to_sym, default: super ) if defined?(super) && super.present?
  end

  def name_with_surrounding
    name
  end

  def extensive_name
    if has_flag? :attendees
      name + (parent_events.first ? ": " + parent_events.first.name : '')
    elsif has_flag? :contact_people
      name + (parent_events.first ? ": " + parent_events.first.name : '')
    elsif has_flag?(:admins_parent) && parent_groups.first.try(:parent_groups).try(:first)
      name + ": " + parent_groups.first.parent_groups.first.name
    elsif super.present?
      super
    else
      name
    end
  end

  def name_with_corporation
    if self.corporation_id && (self.corporation_id != self.id)
      "#{self.name} (#{self.corporation.name})"
    else
      self.name
    end
  end

  # This sets the format of the Group urls to be
  #
  #     example.com/groups/24-planeswalkers
  #
  # rather than just
  #
  #     example.com/groups/24
  #
  def to_param
    "#{id} #{title}".parameterize
  end


  # Mark this group of groups, i.e. the primary members of the group are groups,
  # not users. This does not effect the DAG structure, but may affect the way
  # the group is displayed.
  #
  def group_of_groups?
    has_flag? :group_of_groups
  end
  def group_of_groups=(add_the_flag)
    add_the_flag ? add_flag(:group_of_groups) : remove_flag(:group_of_groups)
  end



  # Associated Objects
  # ==========================================================================================

  # Workflows
  # ------------------------------------------------------------------------------------------

  # These methods override the standard methods, which are usual ActiveRecord associations
  # methods created by the acts-as-dag gem
  # (https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/dag.rb).
  # But since the Workflow in the main application
  # inherits from WorkflowKit::Workflow and single table inheritance and polymorphic
  # associations do not always work together as expected in rails, as can be seen here
  # http://stackoverflow.com/questions/9628610/why-polymorphic-association-doesnt-work-for-sti-if-type-column-of-the-polymorph,
  # we have to override these methods.
  #
  # ActiveRecord associations require 'WorkflowKit::Workflow' to be stored in the database's
  # type column, but by asking for the `child_workflows` we want to get òbjects of the
  # `Workflow` type, not `WorkflowKit::Workflow`, since Workflow objects may have
  # additional methods, added by the main application.
  #
  def descendant_workflows
    Workflow
      .joins( :links_as_descendant )
      .where( :dag_links => { :ancestor_type => "Group", :ancestor_id => self.id } )
      .distinct
  end

  def child_workflows
    self.descendant_workflows.where( :dag_links => { direct: true } )
  end


  # Adress Labels (PDF)
  # options:
  #   - sender:      Sender line including sender address.
  #   - book_rate:   Whether the "Büchersendung"/"Envois à taxe réduite" badge
  #                  is to be printed.
  #   - filter:      ["without_email", "with_local_postal_mail_subscription"]
  #
  def members_to_pdf(options = {sender: '', book_rate: false, type: "AddressLabelsPdf"})
    @filter = options[:filter]
    #timestamp = cached_members_postal_addresses_created_at || Time.zone.now
    timestamp = Time.zone.now
    options[:type].constantize.new(members_postal_addresses, title: self.title, updated_at: timestamp, **options).render
  end
  def members_postal_addresses
    # Sort alphabetically:
    members
      .apply_filter(@filter)
      .order(:last_name, :first_name)
      .collect { |user| user.address_label }

    # # Sort by address:
    # members
    #   .apply_filter(@filter)
    #   .collect { |user| user.address_label }
    #   .sort_by { |address_label| (not address_label.country_code == 'DE').to_s + address_label.country_code.to_s + address_label.postal_code.to_s }
  end

  # def cached_members_postal_addresses_created_at
  #   Rails.cache.fetch [self.cache_key, "cached_members_postal_addresses_created_at", @filter] do
  #     members.apply_filter(@filter).collect { |user| user.cache_created_at(:address_label) || Time.zone.now }.min
  #   end
  # end


  # Groups
  # ------------------------------------------------------------------------------------------

  def descendant_groups_by_name( descendant_group_name )
    self.descendant_groups.where( :name => descendant_group_name )
  end

  def corporation
    Corporation.find corporation_id if corporation_id
  end
  def corporation_id
    (([self.id] + ancestor_group_ids) & Corporation.pluck(:id)).first
  end

  def corporation?
    kind_of? Corporation
  end

  # This returns all sub-groups of the corporation that have no
  # sub-groups of their ownes except for officer groups.
  # This is needed for the selection of status groups.
  #
  def leaf_groups
    Group.find(leaf_group_ids)
  end
  def leaf_group_ids
    self.descendant_groups.order('id').includes(:flags).select { |group|
      group.has_no_subgroups_other_than_the_officers_parent? and not group.is_officers_group?
    }.map(&:id)
  end

  def status_groups
    descendant_groups.where(type: "StatusGroup")
  end
  def status_group_ids
    status_groups.pluck(:id)
  end
  def status_group_tree
    child_groups_with_status_groups.collect do |child_group|
      {
        id: child_group.id,
        name: child_group.name,
        type: child_group.type,
        children: child_group.status_group_tree
      }
    end
  end
  def status_group_tree_ids
    child_groups_with_status_groups.collect { |child_group| [child_group, child_group.descendant_groups] }.flatten.map(&:id)
  end
  def child_groups_with_status_groups
    child_groups & (status_groups + status_groups.map(&:ancestor_groups)).flatten
  end
  def status_groups_with_level(group_hash_array = status_group_tree, level = 0)
    group_hash_array.collect do |entry|
      entry[:level] = level
      children = status_groups_with_level(entry[:children], level + 1)
      entry[:children] = nil
      [entry, children]
    end.flatten
  end

  def find_deceased_members_parent_group
    self.descendant_groups.where(name: ["Verstorbene", "Deceased"]).limit(1).first
  end
  def deceased
    find_deceased_members_parent_group
  end

  # This is an alias for the group that represents the main organization.
  # This is, for example, used to determine when the membership in the
  # main org ended.
  #
  # Feel free to override this method in the main app to match your
  # organizational structure.
  #
  def self.main_org
    self.corporations_parent
  end

  include GroupCaching if use_caching?
end

