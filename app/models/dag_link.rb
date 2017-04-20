class DagLink < ApplicationRecord

  acts_as_dag_links polymorphic: true

  def title
    "Link #{ancestor_type} #{ancestor_id} --> #{descendant_type} #{descendant_id}"
  end

  include DagLinkTypes
  include DagLinkRepair
  include DagLinkCaching if use_caching?

end
