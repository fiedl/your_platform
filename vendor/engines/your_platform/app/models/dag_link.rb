# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  def save( *args )
    delete_cache_daglink
    super( *args )
  end

  def delete_cache_daglink
    descendant.delete_cache if descendant.try(:respond_to?, :delete_cache)
  end

end
