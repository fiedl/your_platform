concern :DagLinkTypes do

  included do
    before_validation :change_type_according_to_other_attributes
  end

  def change_type_according_to_other_attributes
    self.type = "Membership" if ancestor_type == "Group" and descendant_type == "User"
    self.type = "Memberships::Status" if self.type == "Membership" and ancestor.kind_of?(StatusGroup)
  end

end