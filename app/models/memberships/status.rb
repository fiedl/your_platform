# This represents a membership in a status group.
#
# Before making this class STI with type column, this has been
# called `StatusGroupMembership`.
#
class Memberships::Status < Membership

  after_save :apply_gap_correction

  include ::StatusMembershipFinders

  def model_name
    Membership.model_name
  end

end