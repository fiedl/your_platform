# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  after_create :delete_cache
  after_save :delete_cache
  
  def delete_cache
    ancestor.delete_cache if ancestor.try(:respond_to?, :delete_cache)
    descendant.delete_cache if descendant.try(:respond_to?, :delete_cache)
    self.becomes(UserGroupMembership).delete_cached_valid_from
  end
end
