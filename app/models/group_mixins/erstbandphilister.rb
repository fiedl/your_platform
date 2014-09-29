#
# This module extends the Group model by methods for the interaction erstbandphilister groups,
# which are so-called special groups.
#
module GroupMixins::Erstbandphilister

  extend ActiveSupport::Concern

  included do
  end


  # Finder and Creator Methods
  # ------------------------------------------------------------------------------------------
  
  def is_erstbandphilister_parent_group?
    self.has_flag?( :erstbandphilister_parent_group ) and
      ( self.parent_groups.first.has_flag?( :philisterschaft ) or
        self.parent_groups.first.name == "Philisterschaft" 
        )
  end

  def find_erstbandphilister_parent_group
    self.child_groups.find_by_flag( :erstbandphilister_parent_group )
  end

  def create_erstbandphilister_parent_group
    if not find_erstbandphilister_parent_group
      if self.name == "Philisterschaft" 
        erstbandphilister = self.child_groups.create( name: "Erstbandphilister" )
        erstbandphilister.add_flag( :erstbandphilister_parent_group )
        return erstbandphilister
      else
        raise 'erstbandphilister_parent_group has to be a child of a philisterschaft group'
      end
    else
      raise 'erstbandphilister_parent_group already exists'
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
      STDOUT.sync = true
      Corporation.all.each do |corporation|
        philisterschaft = corporation.philisterschaft
        if philisterschaft
          erstbandphilister = philisterschaft.find_erstbandphilister_parent_group
          if not erstbandphilister
            erstbandphilister = philisterschaft.create_erstbandphilister_parent_group
            print ".".green unless Rails.env.test?
          else
            print ".".yellow unless Rails.env.test?
          end
        else
          print ".".red unless Rails.env.test?
        end
      end
      print "\n" unless Rails.env.test?
    end
  end


  # Redefined User Association Methods
  # ------------------------------------------------------------------------------------------

  def members
    if is_erstbandphilister_parent_group?
      
      philisterschaft = self.parent_groups.first
      if not philisterschaft.name == "Philisterschaft" 
        raise error 'the parent_group if this erstbandphilister group is not a philisterschaft group'
      end
      corporation = philisterschaft.parent_groups.first.becomes( Corporation )

      erstbandphilister_user_ids = philisterschaft.members.select do |user|
        # a user is erstbandphilister of a corporation if the corporation is the
        # first corporation the user has joined.
        #
        corporation.is_first_corporation_this_user_has_joined?( user )
      end.collect { |user| user.id }
                  
      return User.where(id: erstbandphilister_user_ids)   # => <ActiveRecord::Relation ...>
    else
      return super
    end
  end
  
  def memberships
    if is_erstbandphilister_parent_group?
      membership_ids = self.corporation.philisterschaft.memberships_including_members.select do |membership|
        membership.user.first_corporation == corporation
      end.collect { |membership| membership.id }
      UserGroupMembership.where(id: membership_ids)
    else
      super
    end
  end
  
  def direct_members
    if is_erstbandphilister_parent_group?
      return members
    else
      return super
    end
  end

end
