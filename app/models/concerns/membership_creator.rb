concern :MembershipCreator do

  class_methods do
  end

  # The regular destroy method won't trigger DagLink's callbacks properly,
  # causing the former dag link bug. By calling the DagLink's destroy method
  # we'll ensure the callbacks are called and indirect memberships are destroyed
  # correctly.
  #
  def destroy
    self.becomes(DagLink).destroy
  end

end