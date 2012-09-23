FactoryGirl.define do

  # workflow step
  # 
  factory :step, :class => WorkflowKit::Step do
    
    brick_name "TestBrick"
    sequence( :sequence_index ) { |n| n }

  end


  # workflow
  #
  factory :workflow do

    sequence( :name ) { |n| "Workflow #{n}" }
    description "This is the description of the workflow."
    
    FactoryGirl.create_list( :step, 3 )

  end



end
