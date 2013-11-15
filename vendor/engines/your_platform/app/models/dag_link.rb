# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base
  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true
  
  # Validity Range Scopes and Methods
  # ====================================================================
  
  def self.default_scope
    self.now
  end
  
  def self.now_and_in_the_past
    unscoped
  end
  
  def self.now
    where("
      ( #{table_name}.valid_from is null OR #{table_name}.valid_from <= ? )
      AND ( #{table_name}.valid_to is null OR #{table_name}.valid_to >= ? )
    ", Time.zone.now, Time.zone.now)
  end
  
  def self.in_the_past
    unscoped.where("
      #{table_name}.valid_to < ?
    ", Time.zone.now)
  end
  
  def make_invalid
    update_attribute(:valid_to, Time.zone.now)
  end
  
  def archive
    make_invalid
  end
  
end
