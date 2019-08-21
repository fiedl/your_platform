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

    has_many :child_pages, through: :links_as_parent, source: :descendant, source_type: "Page", inverse_of: :parent_pages
    has_many :parent_pages, through: :links_as_child, source: :ancestor, source_type: "Page", inverse_of: :child_pages

  end


  def recursive_parent_groups
    Group.where id: (parent_groups + parent_groups.collect { |g| g.recursive_parent_groups }.flatten).map(&:id)
  end

  def ancestor_groups
    recursive_parent_groups
  end

  def ancestor_group_ids
    ancestor_groups.map(&:id)
  end

  def recursive_child_groups
    Group.where id: (child_groups + child_groups.collect { |g| g.recursive_child_groups }.flatten).map(&:id)
  end

  def descendant_groups
    recursive_child_groups
  end


  def recursive_parent_pages
    Page.where id: (parent_pages + parent_pages.collect { |g| g.recursive_parent_pages }.flatten).map(&:id)
  end

  def ancestor_pages
    recursive_parent_pages
  end

end