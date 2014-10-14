# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  # We have to workaround a bug in Rails 3 here. But, since Rails 3 is no longer fully supported,
  # this is not going to be fixed.
  # 
  # https://github.com/rails/rails/issues/7618
  #
  # With our workaround, the `delete_cache` method is called on the `DagLink` when
  # `group.members.destroy(user)` is called.
  # 
  # See: app/models/active_record_associations_patches.rb
  #
  after_save :delete_cache
  before_destroy :delete_cache
  
  def fill_cache
    valid_from
  end

  def delete_cache
    super
    if direct?
      ancestor.delete_cache
      descendant.delete_cache
    end
  end
end
