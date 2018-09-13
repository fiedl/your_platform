concern :UserDag do
  included do
    # has_dag_links             ancestor_class_names: %w(Page Group Event), descendant_class_names: %w(Page), link_class_name: 'DagLink'

    has_many :links_as_descendant, as: :descendant, class_name: "DagLink"
    has_many :links_as_child, -> { where(direct: true) }, as: :descendant, class_name: "DagLink"

    has_many :current_links_as_descendant, -> { now }, as: :descendant, class_name: "DagLink"
    has_many :current_links_as_child, -> { now.direct }, as: :descendant, class_name: "DagLink"

    has_many :ancestor_groups, through: :links_as_descendant, source: :ancestor, source_type: "Group", inverse_of: :descendant_users
    has_many :parent_groups, through: :links_as_child, source: :ancestor, source_type: "Group", inverse_of: :child_users

    has_many :current_ancestor_groups, through: :current_links_as_descendant, source: :ancestor, source_type: "Group", inverse_of: :current_descendant_users
    has_many :current_parent_groups, through: :current_links_as_child, source: :ancestor, source_type: "Group", inverse_of: :current_child_users
  end
end