# The members of this special group type are defined by their
# address being within a certain raidius of a given center.
#
#     radius_center_address: String
#     radius_in_km: Integer
#
# Also, we need a selector on the corporation status.
#
# This is a temporary solution, which is likely to be replaced
# with something more customizable, later.
#
class RadiusGroup < Group

  include RailsSettings::Extend
  delegate :radius_center_address=,
    :radius_in_km, :radius_in_km=,
    :around_group_id, :around_group_id=,
    to: :settings

  def corporation
    Corporation.find(around_group_id) if around_group_id
  end

  def members
    User.where id: member_ids
  end

  def member_ids
    apply_status_selector(users_within_radius).map(&:id)
  end

  def radius_center_address
    settings.radius_center_address || corporation.address_profile_fields.first.value
  end

  private

  def users_within_radius
    User.within radius_in_km: self.radius_in_km, around: self.radius_center_address
  end

  def apply_status_selector(users)
    users.select do |user|
      user.alive? &&
      user.wingolfit? &&
      user.aktiver? &&
      (not user.corporations.include? corporation)
    end
  end

  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end

end