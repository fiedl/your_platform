concern :WorkflowCaching do
  included do
    include StructureableRoleCaching
  end

  def fill_cache
    super
    parent.members.each { |user| user.workflows_by_corporation } if parent && parent.kind_of?(Group)
  end
end