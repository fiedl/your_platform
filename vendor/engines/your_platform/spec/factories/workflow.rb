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

  # workflow to promote a user from one status group to another
  # required parameters: remove_from_group_id, add_to_group_id
  #
  factory :promotion_workflow, :class => Workflow do 
    
    ignore do
      remove_from_group_id 0
      add_to_group_id 0
    end

    sequence( :name ) { |n| "Promotion Workflow #{n}" }

    after( :create ) do |workflow, evaluator|
      workflow.steps.create( brick_name: "RemoveFromGroupBrick", parameters: { :group_id => evaluator.remove_from_group_id } )
      workflow.steps.create( brick_name: "AddToGroupBrick", parameters: { :group_id => evaluator.add_to_group_id } )
    end
    
  end


end
