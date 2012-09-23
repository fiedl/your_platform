module WorkflowKit
  class TestBrick < WorkflowKit::Brick
    
    def description 
      "This is a dummy description of the workflow brick 'TestBrick'."
    end
    
    def execute( params = {} )
      return "TestBrick has been executed."
    end

  end
end
