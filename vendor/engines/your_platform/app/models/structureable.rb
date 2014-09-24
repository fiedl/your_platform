# -*- coding: utf-8 -*-

# This module provides the ActiveRecord::Base extension `is_structureable`, which characterizes
# a model as part of the global dag_link structure in this project. All structureable objects
# are nodes of this dag link.
# 
# Examples: 
#     @page1.parent_pages << @page2
#     @page1.parents # => [ @page2, ... ]
#     
#     @group.child_users << @user
#     @group.children # => [ @user, ... ]
#     @user.parents # => [ @group, ... ]
# 
# For all methods that are provided, please consult the documentations of the 
# `acts-as-dag` gem and of the `acts_as_paranoid_dag` gem.
# 
# This module is included in ActiveRecord::Base via an initializer at
# config/initializers/active_record_structureable_extension.rb
#
module Structureable

  # options: ancestor_class_names, descendant_class_names

  # This method is used to declare a model as structureable, i.e. part of the global 
  # dag link structure. 
  # 
  # Options:
  #   ancestor_class_names
  #   descendant_class_names
  #   link_class_name         (default: 'DagLink')
  # 
  # For detailed information on the options, please see the documentation of the
  # `acts-as-dag` gem, since these options are forwarded to the has_dag_links method.
  # http://rubydoc.info/github/resgraph/acts-as-dag/Dag#has_dag_links-instance_method
  # 
  # Example:
  #     class Group < ActiveRecord::Base
  #       is_structureable ancestor_class_names: %w(Group), descendant_class_names: %w(Group User)
  #     end
  #     class User < ActiveRecord::Base
  #       is_structureable ancestor_class_names: %w(Group)
  #     end
  # 
  def is_structureable( options = {} )
    
    # default options
    conf = {
      :link_class_name => 'DagLink'
    }
    conf.update( options )

    # the model is part of the dag link structure. see gem `acts-as-dag`
    has_dag_links    conf

    
    before_destroy   :destroy_links

    # see Flagable model.
    has_many_flags

    # Structureable objects may have special_groups as descendants, e.g. the admins_parent group.
    # This mixin loads the necessary methods to interact with them.
    #
    include StructureableMixins::HasSpecialGroups
    
    # To use `prepend` here allows to call `super` in the methods
    # defined in the module `StructureableInstanceMethods`.
    #
    prepend StructureableInstanceMethods
  end

  module StructureableInstanceMethods
    
    # Include Rules, e.g. let this object have admins.
    # 
    include StructureableMixins::Roles

    # When a dag node is destroyed, also destroy the corresponding dag links.
    # Otherwise, there would remain ghost dag links in the database that would
    # corrupt the integrity of the database. 
    # 
    # If the database gets ever messed up like this, delete the concerning
    # *direct* dag links by hand and then run this rake task to re-create
    # the indirect dag links:
    # 
    #    rake reconstruct_indirect_dag_links:all
    # 
    def destroy_dag_links

      # destory only child and parent links, since the indirect links
      # are destroyed automatically by the DagLink model then.
      links = self.links_as_parent + self.links_as_child 

      for link in links do

        if link.destroyable?
          link.destroy
        else

          # In facty, all these links should be destroyable. If this error should
          # be raised, something really went wrong. Please send in a bug report then
          # at http://github.com/fiedl/your_platform.
          raise "Could not destroy dag links of the structureable object that should be deleted." +
            " Please send in a bug report at http://github.com/fiedl/your_platform."
          return false
        end  

      end  
    end
    
    # This somehow identifies which are the ancestors of this structureable.
    # For example, this is used in the breadcrumb helper.
    #
    def ancestors_cache_key
      "Group#{ancestor_group_ids if respond_to?(:ancestor_group_ids)}Page#{ancestor_page_ids if respond_to?(:ancestor_page_ids)}User#{ancestor_user_ids if respond_to?(:ancestor_user_ids)}"
    end
    def children_cache_key
      "Group#{child_group_ids.sum if respond_to?(:child_group_ids)}Page#{child_page_ids.sum if respond_to?(:child_page_ids)}User#{child_user_ids.sum if respond_to?(:child_user_ids)}"
    end

    def destroy_links
      self.destroy_dag_links
    end
    
  end
end
