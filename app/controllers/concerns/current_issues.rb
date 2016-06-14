concern :CurrentIssues do

  included do
    helper_method :current_issues
  end

  def current_issues
    if can? :manage, :all_issues
      Issue.all.unresolved
    elsif current_user
      Issue.by_admin(current_user).unresolved
    else
      Issue.none
    end
  end

end