# During App-Store approval, we must give a dummy user access to our platform.
# But he should not be able to access any real data.
#
class Abilities::DummyAbility < Abilities::BaseAbility

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

end
