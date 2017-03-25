class DagLink < ApplicationRecord

  acts_as_dag_links polymorphic: true

  include DagLinkTypes
  include DagLinkRepair
  include DagLinkCaching if use_caching?

end
