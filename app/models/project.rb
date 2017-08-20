class Project < ApplicationRecord
  attr_accessor :corporation_name

  has_dag_links ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group Page), link_class_name: 'DagLink'

  include Structureable
  include Navable

  def group
    parent_groups.first
  end

end
