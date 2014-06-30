# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base

  attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  acts_as_dag_links polymorphic: true

  def save( *args )
    delete_cache_daglink
    super( *args )
  end

  def delete_cache_daglink
    if self.descendant_type == "User"
      if User.exists?( self.descendant_id )
        desc_user = User.find( self.descendant_id )
      end
    end
    if desc_user
      desc_user.delete_cache
    end
    if self.ancestor_type == "Event"
      if Event.exists?( self.ancestor_id )
        ancestor = Event.find( self.ancestor_id )
      end
    end
    if self.ancestor_type == "Group"
      if Group.exists?( self.ancestor_id )
        ancestor = Group.find( self.ancestor_id )
      end
    end
    if self.ancestor_type == "Page"
      if Page.exists?( self.ancestor_id )
        ancestor = Page.find( self.ancestor_id )
      end
    end
    if self.ancestor_type == "User"
      if User.exists?( self.ancestor_id )
        ancestor = User.find( self.ancestor_id )
      end
    end
    if self.ancestor_type == "Workflow"
      if Workflow.exists?( self.ancestor_id )
        ancestor = Workflow.find( self.ancestor_id )
      end
    end
    if ancestor
#      ancestor.delete_cache_structureable
    end
  end

end
