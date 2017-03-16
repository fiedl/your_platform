module ProfileFields

  # Organisation Membership Information
  #
  # An organization entry represents the activity of a user in an organization.
  # Such an entry could be:
  #
  #    the user is "Lead Singer" of "the Band XYZ" since "May 2007"
  #
  # Therefore, this profile_field has got a sub-structure.
  #
  #    Organization  <-- label of the parent profile field
  #         |--------- ProfileField:  :label => :from
  #         |--------- ProfileField:  :label => :to
  #         |--------- ProfileField:  :label => :role
  #
  class Organization < ProfileField
    def self.model_name; ProfileField.model_name; end

    has_child_profile_fields :from, :to, :role

  end
  
end