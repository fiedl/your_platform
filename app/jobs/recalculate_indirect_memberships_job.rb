# We have direct and indirect memberships with validity ranges.
# The validity ranges of indirect memberships is calculated from
# the ranges of the direct memberships.
#
# After a direct membership's validity range has changed, the
# ranges of the dependent indirect memberships have to be updated.
#
# As this takes some time, we've extracted this out into this job.
#
class RecalculateIndirectMembershipsJob < ApplicationJob
  queue_as :dag_links

  def perform(direct_membership)
    direct_membership.recalculate_indirect_validity_ranges
  end
end
