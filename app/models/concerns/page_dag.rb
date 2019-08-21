concern :PageDag do
  included do
    #has_dag_links ancestor_class_names: %w(Page User Group Event), descendant_class_names: %w(Page User Group Event), link_class_name: 'DagLink'

    has_many :links_as_ancestor, as: :ancestor, class_name: "DagLink"
    has_many :links_as_descendant, as: :descendant, class_name: "DagLink"

    has_many :child_pages, through: :links_as_ancestor, as: :ancestor, class_name: "Page", source: :descendant, source_type: "Page"
    has_many :parent_pages, through: :links_as_descendant, as: :descendant, class_name: "Page", source: :ancestor, source_type: "Page"
  end

  def parents
    parent_pages
  end
end