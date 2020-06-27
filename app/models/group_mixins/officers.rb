#
# This module contains the extensions of the Group model that concern officers groups.
#
# Note that the majority of the officers functionality is handled by the Structureable model,
# since officers groups can be also assigned to Pages etc. and not only to Groups.
#
# See:
#   * app/models/structureable_mixins/roles.rb
#   * app/models/structureable_mixins/has_special_groups.rb
#
module GroupMixins::Officers

  extend ActiveSupport::Concern

  included do
  end

  # This method determines if the group has no subgroups other than the officers
  # special group. This is used to determine whether the group is a status group.
  #
  def has_no_subgroups_other_than_the_officers_parent?
    #
    # TODO: Refactor this!
    #
    (self.child_groups - self.child_groups.where(name: ["Amtsträger", "officers"])).count == 0

    # (self.child_groups.count == 0) or
    #   ((self.child_groups.count == 1) and (self.child_groups.first.has_flag?(:officers_parent)))
  end

  # This method determines if the group is an officers group.
  #
  def is_officers_group?
    self.ancestor_groups.find_all_by_flag(:officers_parent).count > 0
  end

  # This returns whether the group is special.
  # This means that the group is special, e.g.
  # an officers group
  def is_special_group?
    self.has_flag?( :officers_parent ) or
    self.ancestor_groups.select do |ancestor|
      ancestor.has_flag?(:officers_parent)
    end.any?
  end

  class_methods do

    # `Group.global_admins` refers to the group
    # of the global administrators.
    #
    def global_admins
      Group.everyone.admins_parent
    end

    def find_global_admins_parent
      Group.find_everyone_group.try(:find_admins_parent_group)
    end

  end

  def important_officers_keys
    [:president, :ceo, :cto, :king, :emperor, :chair]
  end

  def important_officers
    officers_group_ids = officers_groups_of_self_and_descendant_groups.map(&:id)
    entries = []
    important_officers_keys.each do |key|
      Group.where(id: officers_group_ids).flagged(key).each do |group|
        group.members.each do |user|
          entries << {description: group.name, user: user}
        end
      end
    end
    return entries
  end

end
