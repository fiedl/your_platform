concern :ProfileFieldProfileable do

  included do
    belongs_to             :profileable, polymorphic: true

    # For child profile fields, this returns the profileable of the parent.
    # For parents, this returns just the assigned profileable.
    #
    # This has to be here, since child profile fields do not have the
    # `has_child_profile_fields` call in their classes.
    #
    alias_method :orig_profileable, :profileable
    def profileable
      if parent.present?
        parent.profileable
      else
        orig_profileable
      end
    end

    def profileable_title
      profileable.try(:title)
    end

    def profileable_vcard_path
      profileable.vcard_path if profileable.respond_to?(:vcard_path)
    end

    def profileable_alive_and_member?
      profileable.kind_of?(Group) || (profileable.kind_of?(User) && profileable.alive? && !profileable.former_member?)
    end
  end

end