# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct if defined? attr_accessible
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
  after_save { self.delay.delete_cache }
  before_destroy :delete_cache
  
  include DagLinkRepair
  include DagLinkValidityRange
  
  def fill_cache
    valid_from
  end

  def delete_cache
    super
    ancestor.try(:delete_cache)
    descendant.try(:delete_cache)
  end
  
end
