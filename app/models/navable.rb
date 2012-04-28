# -*- coding: utf-8 -*-
# Dieses Modul stellt die Methode +is_navable+ für ActiveRecord::Base zur Verfügung.
# Damit kann ein Model (User, Page, ...) als navigationsfähig (d.h. mit Menü-Elementen, Breadcrumb, etc.)
# deklariert werden.
# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_navable_extension.rb.
module Navable
  def is_navable
    has_one                :nav_node, as: :navable, dependent: :destroy, autosave: true
    before_destroy         :destroy_links
    include InstanceMethodsForNavables
  end
  module InstanceMethodsForNavables
    def is_navable? 
      true
    end

    def nav_node
      node = super
      node = create_nav_node unless node
      return node
    end

    def navnode
      nav_node
    end

    private

    def destroy_links
      links = self.links_as_parent + self.links_as_child
      for link in links do
        if link.destroyable?
          link.destroy
        else
          raise "Could not destroy links of the group that should be deleted." # TODO: Das sollte eigentlich nicht nötig sein.
          return false
        end
      end
    end
  end
end



