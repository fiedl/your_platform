# -*- coding: utf-8 -*-

# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_structureable_extension.rb
module Structureable

  # options: ancestor_class_names, descendant_class_names
  def is_structureable( options = {} )
    
    conf = {
      :link_class_name => 'DagLink'
    }
    conf.update( options )

    has_dag_links    conf

    before_destroy   :destroy_links

    include StructureableInstanceMethods
  end

  module StructureableInstanceMethods

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
