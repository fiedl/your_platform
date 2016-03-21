# We don't want to track the behaviour of a specific user. Instead,
# we track the visits per group.
#
# That way, based on the group memberships, we can guess
# navables of interest.
#
class NavableVisit < ActiveRecord::Base
  belongs_to :navable, polymorphic: true
end
