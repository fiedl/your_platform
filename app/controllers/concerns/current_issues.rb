concern :CurrentIssues do
  
  included do
    helper_method :current_issues
  end

  def current_issues
    if can? :manage, :all_issues
      Issue.all.unresolved
    else
      Issue.by_admin(current_user).unresolved
    end
  end

end