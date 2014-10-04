# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  after_create :delete_cache
  after_save :delete_cache
  before_destroy :delete_cache
  
  def fill_cache
    valid_from
  end

  def delete_cache
    super
    ancestor.delete_cache
    descendant.delete_cache
  end
end
