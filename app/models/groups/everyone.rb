# That special group has all users as members.
#
class Groups::Everyone < Group
  after_create { add_flag(:everyone) }

  def members
    User.all
  end

  def direct_members
    User.all
  end

  def member_table_rows
    User.all.includes(:direct_memberships).collect do |user|
      joined_at = user.direct_memberships.with_past.order(:valid_from).pluck(:valid_from).first
      joined_at = nil if joined_at && joined_at.year < 1700 # Protect from "ArgumentError: year too big to marshal: 17 UTC"
      {
        user_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        name_affix: user.name_affix,
        joined_at: joined_at
      }
    end
  end

  def self.find_or_create
    self.first || self.create
  end

  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end

  cache :member_table_rows
end