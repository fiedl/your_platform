# A company is a Group with the type 'Company'.
# If the primary organizational unit is a Company, not a User, this could simplify things.
# 
class Company < Group
  after_save { Company.companies_parent << self }
  
  def self.companies_parent
    self.find_companies_parent_group || self.create_companies_parent_group
  end
  
  def self.find_companies_parent_group
    Group.find_by_flag :all_companies
  end
  
  def self.create_companies_parent_group
    group = Group.create name: 'all_companies'
    group.add_flag :all_companies
    group.add_flag :group_of_groups
    return group
  end
end