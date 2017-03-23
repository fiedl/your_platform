class Workflow < WorkflowKit::Workflow
  # These class methods have been moved to `WorkflowKit:Workflow`, because
  # when accessed through dag links, the objects are instanciated as
  # `WorkflowKit:Workflow` rather than `Workflow`.
  #
  # TODO: This distinction becomes obsolete when migrating to the new
  # workflow model and abandoning workflow_kit.
end
