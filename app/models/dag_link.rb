# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct if defined? attr_accessible
  acts_as_dag_links polymorphic: true

  include DagLinkRepair
  include DagLinkCaching if use_caching?

end
