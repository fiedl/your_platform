class Ability
  include CanCan::Ability

  def initialize(user)
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


    # This behaviour is temporary!
    #
    # Only registered users can do or see anything.
    #
    if user 
      
      # Only global administrators can change anything.
      #
      if Group.find_everyone_group.admins && user.in?(Group.find_everyone_group.admins)
        can :manage, :all
        
      else
        
        # Users that are no admins can read all.
        can :read, :all

        can :manage, User do |profile|
          profile.id == user.id
        end

        can :manage, ProfileField do |field|
          parent_field = field
          while parent_field.parent != nil do
            parent_field = parent_field.parent
          end

          parent_field.profileable.id == user.id
        end

      end

    end
  end
end
