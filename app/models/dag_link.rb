# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base
  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

end
