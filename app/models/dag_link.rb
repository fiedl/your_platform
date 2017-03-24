class DagLink < ApplicationRecord

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct if defined? attr_accessible
  acts_as_dag_links polymorphic: true

  include DagLinkTypes
  include DagLinkRepair
  include DagLinkCaching if use_caching?

end
