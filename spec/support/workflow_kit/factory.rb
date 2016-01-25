# -*- coding: utf-8 -*-
module WorkflowKit
  module Factory

    def create_workflow
      workflow = Workflow.create( name: "Cook Spaghetti",
                                  description: "An example workflow to demonstrate how to use workflows in the `workflow_kit` gem." )

      workflow.steps.create brick_name: "BoilWaterBrick", sequence_index: 1, parameters: { :aim_temperature => '100 °C' }
      workflow.steps.create brick_name: "BoilSpaghettiBrick", sequence_index: 2, parameters: { :time_to_boil => '10 minutes' }
      workflow.steps.create brick_name: "ServeSpaghettiBrick", sequence_index: 3

      return workflow
    end

  end

  class BoilWaterBrick < Brick
    def description
      "Fill a large pot with water, put it on a cooker " +
        "and wait until the given temperature is reached."
    end
    def execute( params )
      return self.description
        .gsub( "the given temperature", "a temperature of " + params[ :aim_temperature ] )
    end
  end

  class BoilSpaghettiBrick < Brick
    def description
      "Add spaghetti and boil them for the given time."
    end
    def execute( params )
      return self.description
        .gsub( "the given time", params[ :time_to_boil ] )
    end
  end

  class ServeSpaghettiBrick < Brick
    def description
      "Sieve spaghetti, put them on a plate, and serve them with " +
        "some yummy ham-cheese-cream sauce."
    end
    def execute( params )
      return self.description
    end
  end

end
