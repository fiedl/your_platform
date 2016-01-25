module WorkflowKit
  class Workflow < ActiveRecord::Base
    self.table_name = "workflow_kit_workflows"

    attr_accessible :description, :name, :parameters

    has_many :steps, dependent: :destroy

    extend WorkflowKit::Parameterable
    has_many_parameters

    def execute( params = {} )
      params = {} unless params
      params = params.merge( self.parameters_to_hash ) if self.parameters.count > 0
      ActiveRecord::Base.transaction do
        self.steps.collect do |step|
          step.execute( params )
        end
      end
    end

    def steps 
      super.order( :sequence_index ).order( :created_at )
    end

  end
end
