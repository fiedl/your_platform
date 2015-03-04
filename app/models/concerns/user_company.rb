module UserCompany
  extend ActiveSupport::Concern
    
  def company_id
    (Company.pluck(:id) & self.ancestor_group_ids).first
  end
  
  # Returns the Company the user is associated with.
  #
  def company
    cached { Company.find company_id if company_id }
  end
  
  # Returns the name of the Company the user is associated with.
  #
  def company_name
    company.try(:name)
  end
  
  # Sets the name of the Company the user is associated with.
  # If no matching company exists, the company is created.
  # The user is added as member to this company.
  #
  def company_name=(new_company_name)
    Company.find_or_create_by_name(new_company_name).assign_user self
  end
  
end