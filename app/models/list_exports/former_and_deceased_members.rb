module ListExports

  class FormerAndDeceasedMembers < Base

    def columns
      [
        :id,
        :last_name,
        :first_name,
        :name_affix,
        :localized_date_of_birth,
        :localized_date_of_death,
        :localized_date_of_org_membership_end,
        :reason_for_membership_end,
        :postal_address_town
      ]
    end

    # Sort the listed users by date of death reversed.
    #
    def data
      group.descendant_users.select { |user|
        user.dead? or user.former_member?
      }
    end

  end
end