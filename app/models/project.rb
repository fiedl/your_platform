class Project < ApplicationRecord
  attr_accessor :corporation_name

  has_many :links_as_child, -> { direct }, as: :descendant, class_name: "DagLink"
  has_many :parent_groups, through: :links_as_child, source: :ancestor, source_type: "Group", inverse_of: :child_groups

  include Structureable
  include Navable

  def group
    parent_groups.first
  end

end
