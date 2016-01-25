module WorkflowKit
  class Brick 

    @@descendants = []

    def self.inherited( descendant_class )
      @@descendants << descendant_class 
    end

    def name
      self.class.name
    end

    def description
    end

    def execute( params )
    end

    def self.all
      @@descendants
    end

    def self.find_by_name( brick_name )
      class_name = "WorkflowKit::#{brick_name}" if brick_name
      return class_name.constantize.new 
    end

  end

# If uncommented, this Brick will also be visible in the application.
# Thus, this should stay commented in production.
#
#  class TestBrick < Brick
#    def description
#      "This is a test brick of the workflow_kit."
#    end
#
#    def execute( params )
#      p "Executing TestBrick"
#      p params
#    end
#  end

end
