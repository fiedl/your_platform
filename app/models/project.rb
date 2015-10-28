class Project < ActiveRecord::Base
  attr_accessible :title, :description, :corporation_name
  attr_accessor :corporation_name

  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group Page)
  is_navable
  
  def group
    parent_groups.first
  end

end
