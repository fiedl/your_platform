module OfficersHelper

  def officer_card(officer_group)
    content_tag :vue_officer_card, "",
      ':initial_office': officer_group.as_json.merge({
        email: officer_group.email,
        avatar_path: officer_group.avatar_path,
        scope: officer_group.scope.as_json
      }).to_json,
      ':initial_officers': officer_group.members.collect { |officer|
        officer.as_json.merge({
          phone: officer.phone,
          email: officer.email
        })
      }.to_json,
      history_path: group_officers_history_path(officer_group),
      ':editable': can?(:update, officer_group).to_json,
      ':can_rename_office': can?(:manage, officer_group).to_json,
      mail_icon: mail_icon,
      phone_icon: smartphone_icon
  end

  def sorted_officers_groups_for(structureable)
    sort_officer_groups(structureable.find_officers_groups)
  end

  def sort_officer_groups(officer_groups)
    officer_groups.sort_by do |group|
      [:main_admins, :admins].index(group.flags.first.try(:to_sym)) || (100 + group.id)
    end
  end

end