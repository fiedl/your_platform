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

  include GroupMemberships
  include GroupMemberAssignment
  include GroupMixins::Everyone  
  include GroupMixins::Corporations
  include GroupMixins::Roles
  include GroupMixins::Guests
  include GroupMixins::HiddenUsers
  include GroupMixins::Developers
  include GroupMixins::Officers
  include GroupMixins::Import
  include GroupMailingLists
  include GroupDummyUsers
  include GroupWorkflows

  after_create     :import_default_group_structure  # from GroupMixins::Import
  after_save       { self.delay.delete_cache }

  def delete_cache
    super
    ancestor_groups(true).each { |g| g.delete_cached(:leaf_groups); g.delete_cached(:status_groups) }
  end
    
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
    I18n.t( super.to_sym, default: super ) if super.present?
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
  #
  def members_to_pdf(options = {sender: '', book_rate: false, type: "AddressLabelsPdf"})
    timestamp = cached_members_postal_addresses_created_at || Time.zone.now
    options[:type].constantize.new(members_postal_addresses, title: self.title, updated_at: timestamp, **options).render
  end
  def members_postal_addresses
    cached do
      members
        .collect { |user| user.address_label }
        .sort_by { |address_label| (not address_label.country_code == 'DE').to_s + address_label.country_code.to_s + address_label.postal_code.to_s }
        # .collect { |address_label| address_label.to_s }
    end
  end
  def cached_members_postal_addresses_created_at
    cached do
      members.collect { |user| user.cache_created_at(:address_label) || Time.zone.now }.min
    end
  end


  # Groups
  # ------------------------------------------------------------------------------------------

  def descendant_groups_by_name(descendant_group_name)
    self.descendant_groups.select { |g| g.name == descendant_group_name }
  end

  def corporation
    cached do
      Corporation.find corporation_id if corporation_id
    end
  end
  def corporation_id
    (([self.id] + connected_ancestor_group_ids) & Corporation.pluck(:id)).first
  end

  def corporation?
    kind_of? Corporation
  end
  
  def find_deceased_members_parent_group
    self.descendant_groups.where(name: ["Verstorbene", "Deceased"]).limit(1).first
  end
  def deceased
    find_deceased_members_parent_group
  end
  
  concerning :GroupDescendantUsers do
    def descendant_users
      raise('Changed interface! Please use `Group#members` or `Group#members.with_past`.')
    end
  end

end

