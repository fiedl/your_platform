# -*- coding: utf-8 -*-
#
# This module provides the +is_navable+ method for ActiveRecord::Base.
# Calling this method marks the model (User, Page, ...) as navable, i.e. has menu, breadcrumbs, etc. 
#
# The inclusion in ActiveRecord::Base is done in
# config/initializers/active_record_navable_extension.rb.
#

module Navable
  def is_navable
    has_one                :nav_node, as: :navable, dependent: :destroy, autosave: true
    
    include InstanceMethodsForNavables
  end
  module InstanceMethodsForNavables
    def is_navable? 
      true
    end
    
    def navable?
      is_navable?
    end

    def nav_node
      node = super
      node = build_nav_node unless node
      return node
    end

    def navnode
      nav_node
    end

    def nav
      nav_node
    end

    def navable_children
      children.select { |child| child.respond_to? :nav_node }
    end

    private

  end
end
