
# This module extends the Group model by methods for the interaction with so called 'special groups'.
# Those special groups are, for example, the group 'everyone' or the 'officers' groups, which are
# subgroups of each group which can have officers. 
# 
# The module is included in the Group model by `include GroupMixins::Special Groups`.
# The methods of the module can be accessed just like any other Group model methods:
#    Group.class_method()
#    g = Group.new()
#    g.instance_method()
#
module GroupMixins::SpecialGroups

  extend ActiveSupport::Concern

  included do
    # see, for example, http://stackoverflow.com/questions/5241527/splitting-a-class-into-multiple-files-in-ruby-on-rails
  end


  # Everyone
  # ==========================================================================================

  module ClassMethods

    # The 'root group', which is the highest in the group hierarchy. 
    # Everyone is member of this group, even not registered users.
    # 
    def everyone
      self.find_everyone_group
    end
    
    def find_everyone_group
      Group.find_by_flag( :everyone )
    end

    def create_everyone_group
      everyone = Group.create( name: 'Everyone' )
      everyone.add_flag( :everyone )
      everyone.name = I18n.translate( :everyone )
      everyone.save
      return everyone
    end
    
  end


  # Corporations Parent
  # ==========================================================================================

  module ClassMethods

    # Parent group for all corporation groups.
    # The group structure looks something like this:
    #
    #   everyone
    #      |----- corporations_parent                     <--- this is the group returned by this method
    #                       |---------- corporation_a
    #                       |                |--- ...
    #                       |---------- corporation_b
    #                       |                |--- ...
    #                       |---------- corporation_c
    #                                        |--- ...
    def corporations_parent
      self.find_corporations_parent_group
    end
    
    def find_corporations_parent_group
      Group.find_by_flag( :corporations_parent )
    end

    def create_corporations_parent_group
      corporations_parent = Group.create( name: "Corporations" )
      corporations_parent.add_flag( :corporations_parent )
      corporations_parent.parent_groups << Group.everyone
      corporations_parent.name = I18n.translate( :corporations_parent )
      corporations_parent.save
      return corporations_parent
    end

    def corporations
      self.find_corporation_groups
    end

    def find_corporation_groups
      self.corporations_parent.child_groups
    end

  end


  # Officers Parent
  # ==========================================================================================

  def officers_parent
    self.find_officers_parent_group
  end

  def officers_parent!
    self.create_officers_parent_group
  end

  def officers
    self.find_officers_groups
  end

  def find_officers_parent_group
    self.child_groups.find_by_flag( :officers_parent ) unless self.has_flag? :officers_parent
  end

  def create_officers_parent_group
    unless self.has_flag? :officers_parent
      officers_parent = self.officers_parent
      unless self.officers_parent
        officers_parent = Group.create( name: I18n.translate( :officers_parent ) )
        officers_parent.parent_groups << self
        officers_parent.add_flag( :officers_parent )
      end
      return officers_parent
    end
  end

  def find_officers_groups
    officers_parents = self.descendant_groups.find_all_by_flag( :officers_parent )
    officers = officers_parents.collect{ |officer_group| officer_group.child_groups }.flatten
    return officers # if officers.count > 0
  end


end
