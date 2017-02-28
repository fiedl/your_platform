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

    # We do not show all kinds of objects in the menu.
    # Therefore select the appropriate items.
    #
    def navable_children
      (respond_to?(:child_groups) ? child_groups : []) +
      (respond_to?(:child_pages) ? child_pages : [])
    end

    private

  end
end
