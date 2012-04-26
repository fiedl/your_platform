class Group < ActiveRecord::Base
  attr_accessible :name

  has_dag_links    link_class_name: 'DagLink', ancestor_class_names: %w(Group), descendant_class_names: %w(Group User)

  def self.jeder
    g = Group.first
    if g.root_for_groups?
      return g
    else
      return g.ancestor_groups.first
    end
  end

end

class Groups 
  
  def self.all
    Group.all
  end

  def self.of_user( user )
    user.ancestor_groups
  end

end
