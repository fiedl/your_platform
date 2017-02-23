# -*- coding: utf-8 -*-
#
# This class represents a user group. Besides users, groups may have sub-groups as children.
# One group may have several parent-groups. Therefore, the relations between groups, users,
# etc. is stored using the DAG model, which is implemented by the `is_structureable` method.
#
class Group < ActiveRecord::Base

  if defined? attr_accessible
    attr_accessible( :name, # just the name of the group; example: 'Corporation A'
                      :body, # a description text displayed on the groups pages top
                      :token, # (optional) a short-name, abbreviation of the group's name, in
                              # a global context; example: 'A'
                      :internal_token, # (optional) an internal abbreviation, i.e. used by the
                                       # members of the group; example: 'AC'
                      :extensive_name, # (optional) a long version of the group's name;
                                       # example: 'The Corporation of A'
                      :direct_members_titles_string # Used for inline-editing: The comma-separated
                                                    # titles of the child users of the group.
                      )
  end

  include ActiveModel::ForbiddenAttributesProtection  # TODO: Move into initializer

  is_structureable(ancestor_class_names: %w(Group Page Event),
                   descendant_class_names: %w(Group User Page Workflow Event Project))
  is_navable
  has_profile_fields

  has_many :posts

  default_scope { includes(:flags) }

  include GroupMixins::Memberships
  include GroupMixins::Everyone
  include GroupMixins::Corporations
  include GroupMixins::Roles
  include GroupMixins::Guests
  include GroupMixins::HiddenUsers
  include GroupMixins::Developers
  include GroupMixins::Officers
  include GroupMixins::Import
  include GroupProfile
  include GroupMailingLists
  include GroupDummyUsers
  include GroupWelcomeMessage
  include GroupSemesterCalendars

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
    if self.corporation && self.corporation.id != self.id
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
      .uniq
  end

  def child_workflows
   self.descendant_workflows.where( :dag_links => { direct: true } )
  end


  # Events
  # ------------------------------------------------------------------------------------------

  def events
    self.descendant_events
  end

  def upcoming_events
    self.events.upcoming.order('start_at')
  end


  # Adress Labels (PDF)
  # options:
  #   - sender:      Sender line including sender address.
  #   - book_rate:   Whether the "Büchersendung"/"Envois à taxe réduite" badge
  #                  is to be printed.
  #   - filter:      ["without_email"]
  #
  def members_to_pdf(options = {sender: '', book_rate: false, type: "AddressLabelsPdf"})
    @filter = options[:filter]
    timestamp = cached_members_postal_addresses_created_at || Time.zone.now
    options[:type].constantize.new(members_postal_addresses, title: self.title, updated_at: timestamp, **options).render
  end
  def members_postal_addresses
    #Rails.cache.fetch [self.cache_key, "members_postal_addresses", @filter] do
      members
        .apply_filter(@filter)
        .collect { |user| user.address_label }
        .sort_by { |address_label| (not address_label.country_code == 'DE').to_s + address_label.country_code.to_s + address_label.postal_code.to_s }
        # .collect { |address_label| address_label.to_s }
    #end
  end
  def cached_members_postal_addresses_created_at
    Rails.cache.fetch [self.cache_key, "cached_members_postal_addresses_created_at", @filter] do
      members.apply_filter(@filter).collect { |user| user.cache_created_at(:address_label) || Time.zone.now }.min
    end
  end


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
    self.descendant_groups.order('id').includes(:flags).select do |group|
      group.has_no_subgroups_other_than_the_officers_parent? and not group.is_officers_group?
    end
  end

  def status_groups
    StatusGroup.find_all_by_group(self)
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

  include GroupCaching
end

