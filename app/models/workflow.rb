class Workflow < WorkflowKit::Workflow  #< ActiveRecord::Base
  attr_accessible    :name

  is_structureable   ancestor_class_names: %w(Group)

  def title
    name
  end

  def name_as_verb
    name
      .gsub( /ung/, 'en' )
      .gsub( /ation/, 'ieren' )
      .downcase
  end

  def wah_group
    ( self.ancestor_groups & Corporation.all ).first
  end

end
