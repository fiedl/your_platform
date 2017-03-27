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
    include NavableBreadcrumbs
    include NavableVerticalNavs
    include NavableCaching if use_caching?
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

    def in_intranet?
      ancestor_navables.include?(Page.intranet_root) || (self.id == Page.intranet_root.id)
    end

  end
end
