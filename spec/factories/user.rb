FactoryGirl.define do

  # regular user
  #
  factory :user do

    sequence( :last_name ) { |n| "Doe#{n}" }
    first_name "John"

    sequence( :alias ) { |n| "j.doe#{n}" }
    sequence( :email ) { |n| "j.doe#{n}@example.com" }

    trait :with_profile_fields do
      after :create do |user|
        user.profile_fields.create(type: ProfileFields::Employment.name)
      end
    end

    trait :with_address do
      after :create do |user|
        user.profile_fields.create(type: ProfileFields::Address.name)
      end
    end

    trait :with_postal_address do
      after :create do |user|
        address_field = user.profile_fields.create(type: ProfileFields::Address.name)
        address_field.postal_address = true
      end
    end

    trait :with_bank_account do
      after :create do |user|
        user.profile_fields.create(type: ProfileFields::BankAccount.name)
      end
    end

    trait :with_corporate_vita do
      after :create do |user|
        corporation = create( :corporation_with_status_groups )
        status_groups = corporation.child_groups
        status_groups.first.assign_user user

        first_promotion_workflow = create( :promotion_workflow, name: 'First Promotion',
                                            :remove_from_group_id => status_groups.first.id,
                                            :add_to_group_id => status_groups.second.id )
        first_promotion_workflow.parent_groups << status_groups.first

        second_promotion_workflow = create( :promotion_workflow, name: 'Second Promotion',
                                             :remove_from_group_id => status_groups.second.id,
                                             :add_to_group_id => status_groups.last.id )
        second_promotion_workflow.parent_groups << status_groups.second
      end
    end

    trait :hidden do
      after :create do |user|
        user.hidden = true
      end
    end

    trait :dead do
      after :create do |user|
        user.set_date_of_death_if_unset 1.day.ago
      end
    end

    trait :accepted_terms_of_use do
      after :create do |user|
        user.accept_terms TermsOfUseController.current_terms_stamp
      end
    end

    # user with associated user account
    #
    factory :user_with_account do
      create_account true
    end

    # global administrator
    # this is just temporary, until the structured role model is ready.
    # TODO: Remove this when ready!
    #
    factory :admin do
      create_account true

      after :create do |admin|
        Group.find_everyone_group.assign_admin admin
      end
    end

    factory :local_admin do
      transient do
        of nil  # syntax: create(:local_admin, of: @group)
      end
      create_account true
      after :create do |admin, evaluator|
        raise 'Please set object to administrate, e.g.:  create :local_admin, of: @group' unless evaluator.of.respond_to?(:admins)
        evaluator.of.assign_admin admin
      end
    end

  end
end
