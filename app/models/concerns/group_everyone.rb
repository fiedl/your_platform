# This concerns accessors to the special group "everyone"
# through the `Group` class. The everyone group itself is
# defined in `Groups::Everyone`.
#
concern :GroupEveryone do
  class_methods do

    def everyone
      Groups::Everyone.find_or_create
    end

    def find_or_create_everyone_group
      Groups::Everyone.find_or_create
    end

    def find_everyone_group
      Groups::Everyone.first
    end

    def create_everyone_group
      Groups::Everyone.create
    end

    def everyone!
      find_everyone_group || raise(ActiveRecord::RecordNotFound, 'special group Groups::Everyone does not exist.')
    end

  end
end