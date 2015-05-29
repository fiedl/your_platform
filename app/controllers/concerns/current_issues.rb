concern :CurrentIssues do
  
  included do
    helper_method :current_issues
  end

  def current_issues
    if can? :manage, :all_issues
      Issue.all
    else
      Issue.by_admin(current_user)
    end
  end

end