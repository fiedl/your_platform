concern :GroupDag do
  included do
    #has_dag_links ancestor_class_names: %w(Group Page Event), descendant_class_names: %w(Group User Page Workflow Project), link_class_name: 'DagLink'

    has_many :links_as_ancestor, as: :ancestor, class_name: "DagLink"
    has_many :links_as_descendant, as: :descendant, class_name: "DagLink"
    has_many :links_as_parent, -> { direct }, as: :ancestor, class_name: "DagLink"
    has_many :links_as_child, -> { direct }, as: :descendant, class_name: "DagLink"

    has_many :current_links_as_ancestor, -> { now }, as: :ancestor, class_name: "DagLink"
    has_many :current_links_as_parent, -> { now.direct }, as: :ancestor, class_name: "DagLink"

    has_many :child_groups, through: :links_as_parent, source: :descendant, source_type: "Group", inverse_of: :parent_groups
    has_many :parent_groups, through: :links_as_child, source: :ancestor, source_type: "Group", inverse_of: :child_groups

    has_many :descendant_users, through: :links_as_ancestor, source: :descendant, source_type: "User", inverse_of: :ancestor_groups
    has_many :child_users, through: :links_as_parent, source: :descendant, source_type: "User", inverse_of: :parent_groups

    has_many :current_descendant_users, through: :current_links_as_ancestor, source: :descendant, source_type: "User", inverse_of: :current_ancestor_groups
    has_many :current_child_users, through: :current_links_as_parent, source: :descendant, source_type: "User", inverse_of: :current_parent_groups

  end

  def recursive_parent_groups
    parent_groups + parent_groups.collect { |g| g.recursive_parent_groups }.flatten
  end

  # def ancestor_groups
  #   recursive_parent_groups
  # end
end