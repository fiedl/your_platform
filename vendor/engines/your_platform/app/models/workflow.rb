class Workflow < WorkflowKit::Workflow  #< ActiveRecord::Base
  attr_accessible    :name

  is_structureable   ancestor_class_names: %w(Group)

  def title
    name
  end

  def name_as_verb
    
    # TODO: This is German only! Internationalize!
    name
      .gsub( /ung/, 'en' )
      .gsub( /ation/, 'ieren' )
      .downcase
  end

  def wah_group  # => TODO: corporation
    ( self.ancestor_groups & Corporation.all ).first
  end
  
  def self.find_or_create_mark_as_deceased_workflow
    Workflow.where(name: "Todesfall").first || self.create_mark_as_deceased_workflow
  end
  
  def self.create_mark_as_deceased_workflow
    raise 'Workflow already present.' if Workflow.where(name: "Todesfall").first
    workflow = Workflow.create(name: "Todesfall")
    step = workflow.steps.build
    step.sequence_index = 1
    step.brick_name = "MarkAsDeceasedBrick"
    step.save
    return workflow
  end
end
