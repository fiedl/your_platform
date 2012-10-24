# -*- coding: utf-8 -*-
class Relationship < ActiveRecord::Base

  # Beziehungen zwischen Benutzern,
  # z.B.  Benutzer A ist der Schwiegervater von Benutzer B.
  #       ----------         --------------     ----------
  #       (who)              (is)               (of)

  attr_accessible :name, :who, :is, :of, :who_by_title, :of_by_title

  is_structureable link_class_name: 'RelationshipDagLink', ancestor_class_names: %w(User), descendant_class_names: %w(User)


  def who
    self.parent_users.first
  end
  def who=( user )
    if user.kind_of? User
      for link in self.links_as_child
        link.destroy if link.destroyable?
      end
      self.parent_users << user
    end
  end

  def is
    self.name
  end
  def is=( name )
    self.name = name
  end

  def of 
    self.child_users.first
  end
  def of=( user )
    if user.kind_of? User
      for link in self.links_as_parent
        link.destroy if link.destroyable?
      end
      self.child_users << user
    end
  end


  # Neue Beziehung hinzufügen via:
  # Relationship.add( who: first_user, is: :leibbursch, of: second_user )
  def self.add( params )
    self.create( params )
  end


  def who_by_title
    self.who.title if self.who
  end
  def who_by_title=( title )
    self.who = User.find_by_title( title )
  end
  
  def of_by_title
    self.of.title if self.of
  end
  def of_by_title=( title )
    self.of = User.find_by_title( title )
  end

end
