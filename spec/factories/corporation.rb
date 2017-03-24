FactoryGirl.define do

  factory :corporation do
    sequence(:token) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence(:name) { |n| "The Corporation of #{token.to_s}" }
    sequence(:extensive_name) { |n| "The Great Corporation of the #{token.to_s}" }
    sequence(:internal_token) { |n| "#{token.to_s}C" }

    factory :corporation_with_status_groups do
      after :create do |corporation|
        status1 = corporation.child_groups.create(name: "Member Status 1", type: "StatusGroup")
        status2 = corporation.child_groups.create(name: "Member Status 2", type: "StatusGroup")
        status3 = corporation.child_groups.create(name: "Member Status 3", type: "StatusGroup")
        [status1, status2, status3].each { |g| g.add_flag :full_members } # in contrast to deceased

        status_workflow = Workflow.create name: 'First Promotion', description: "Promotes the user from the first to the second status group."

        # # Does not work:
        # status_workflow.steps.create(brick_name: "RemoveFromGroupBrick", parameters: { :group_id => corporation.status_groups.first.id })
        # status_workflow.steps.create(brick_name: "AddToGroupBrick", parameters: { :group_id => corporation.status_groups.second.id })

        step = status_workflow.steps.create
        step.brick_name = 'RemoveFromGroupBrick'
        step.save
        param = step.parameters.create
        param.key = :group_id
        param.value = corporation.reload.status_groups.first.id
        param.save

        step = status_workflow.steps.create
        step.brick_name = 'AddToGroupBrick'
        step.save
        param = step.parameters.create
        param.key = :group_id
        param.value = corporation.status_groups.second.id
        param.save

        status_workflow.parent_groups << corporation.status_groups.first

      end
    end
  end

end

