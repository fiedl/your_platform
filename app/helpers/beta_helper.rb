module BetaHelper
  def beta_badge_with_link
    if current_user.try(:beta_tester?)
      link_to group_path(Group.find_by_flag(:beta_testers)) do
        beta_badge
      end
    end
  end
  def beta_badge
    content_tag :span, class: 'badge beta_badge has_tooltip', title: "Du hast Zugriff auf Funktionen, die sich in der Erprobungsphase befinden.", data: {placement: 'right'} do
      "+Beta"
    end
  end
end