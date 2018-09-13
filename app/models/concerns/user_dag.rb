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

  def create_indirect_dag_links
    new_links = []
    links_as_child.each do |direct_link|
      direct_group = direct_link.ancestor
      direct_group.recursive_parent_groups.each do |indirect_group|
        new_links << links_as_descendant.find_or_create_by(direct: false, ancestor: indirect_group, descendant: self, valid_from: direct_link.valid_from, valid_to: direct_link.valid_to)
      end
    end
    links_as_descendant.indirect.where.not(id: new_links.collect(&:id)).destroy_all
  end
end