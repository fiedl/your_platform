
# First load the correspondant module from the your_platform engine.
require_dependency YourPlatform::Engine.root.join( 'app/models/group_mixins/special_groups' ).to_s

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

  # Erstbandphilister
  # ==========================================================================================
  
  def is_erstbandphilister_parent_group?
    self.has_flag?( :erstbandphilister_parent_group ) and
      ( self.parent_groups.first.has_flag?( :philisterschaft ) or
        self.parent_groups.first.name == "Philisterschaft" 
        )
  end

  def users
    if is_erstbandphilister_parent_group?
      
      # TODO: definition here
      # and delete this dummy
      philisterschaft = self.parent_groups.first 
      normale_philister = philisterschaft.child_groups.find_by_name( "Philister" )
      ehrenphilister = philisterschaft.child_groups.find_by_name( "Ehrenphilister" )
      return normale_philister.child_users + ehrenphilister.child_users

    else
      return super
    end
  end
  
  def child_users
    if is_erstbandphilister_parent_group?
      return users
    else
      return super
    end
  end

  def descendant_users
    if is_erstbandphilister_parent_group?
      return users
    else
      return super
    end
  end

  def find_erstbandphilister_parent_group
    self.child_groups.find_by_flag( :erstbandphilister_parent_group )
  end

  def create_erstbandphilister_parent_group
    if not find_erstbandphilister_parent_group
      erstbandphilister = self.child_groups.create( name: "Erstband-Philister" )
      erstbandphilister.add_flag( :erstbandphilister_parent_group )
      return erstbandphilister
    end
  end

  def erstbandphilister
    self.find_erstbandphilister_parent_group
  end

  def erstbandphilister!
    erstbandphilister ||= self.find_erstbandphilister_parent_group
    erstbandphilister ||= self.create_erstbandphilister_parent_group
    erstbandphilister
  end

  module ClassMethods

    def create_erstbandphilister_parent_groups
      Wah.all.each do |corporation|
        philisterschaft = corporation.philisterschaft
        erstbandphilister = philisterschaft.find_erstbandphilister_parent_group
        if not erstbandphilister
          erstbandphilister = philisterschaft.create_erstbandphilister_parent_group
        end
      end
    end

  end


end
