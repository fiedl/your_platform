concern :UserStatus do

  included do
    has_many :status_memberships,
        -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
        foreign_key: :descendant_id, class_name: "Memberships::Status"
  end

  # This returns all status groups of the user, i.e. groups that represent the member
  # status of the user in a corporation.
  #
  # options:
  #   :with_invalid  =>  true, false
  #
  def status_groups(options = {})
    if options[:with_invalid]
      self.parent_groups.where(type: "StatusGroup")
    else
      self.direct_groups.where(type: "StatusGroup")
    end
  end
  def status_group_ids(options = {})
    status_groups(options).pluck(:id)
  end

  def current_status_membership_in(corporation)
    Memberships::Status.find_all_by_user_and_corporation(self, corporation).last
  end

  def current_status_group_in(corporation)
    Memberships::Status # make sure this class is loaded (auto-loading issue)
    StatusGroup.find_by_user_and_corporation(self, corporation) if corporation
  end

  def current_status_in(corporation)
    current_status_group_in(corporation).try(:name).try(:singularize)
  end

  def status_group_in_primary_corporation
    # - First try the `first_corporation`,  which does not consider corporations the user is
    #   a former member of.
    # - Next, use all corporations, which applies to completely excluded members.
    #
    current_status_group_in(first_corporation || corporations.first)
  end

  def status_export_string
    self.corporations.collect do |corporation|
      if membership = self.current_status_membership_in(corporation)
        "#{I18n.localize(membership.valid_from.to_date) if membership.valid_from}: #{membership.group.name.try(:singularize)} in #{corporation.name}"
      else
        ""
      end
    end.join("\n")
  end
  def status_string
    status_export_string
  end

  def status
    status_groups
  end

end