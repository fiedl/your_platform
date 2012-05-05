# -*- coding: utf-8 -*-
class Relationship < ActiveRecord::Base
  attr_accessible :name

  has_dag_links link_class_name: 'RelationshipDagLink', ancestor_class_names: %w(User), descendant_class_names: %w(User)

  # Neue Beziehung hinzufügen via:
  # Relationship.add( who: first_user, is: :leibbursch, of: second_user )
  def self.add( params )
    who = params[ :who ] # first user
    is = params[ :is ]   # name of the relation
    of = params[ :of ]   # second user

    if who and is and of
      relationship = Relationship.create( name: is )
      who.relationships_child_relationships << relationship
      of.relationships_parent_relationships << relationship
      return relationship
    end
  end

end
