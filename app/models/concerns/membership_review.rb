concern :MembershipReview do
  
  def needs_review?
    direct? && dag_link.has_flag?(:needs_review)
  end
  
  def needs_review=(new_needs_review)
    new_needs_review = false if new_needs_review == "false"
    direct? || raise('Only direct memberships can be reviewed.')
    dag_link.add_flag :needs_review if new_needs_review
    dag_link.remove_flag :needs_review if not new_needs_review
  end
  
  def needs_review!
    self.needs_review = true
  end  
  
end