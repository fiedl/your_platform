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
        user.profile_fields.create(type: ProfileFieldTypes::Employment.name)
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
        Group.find_everyone_group.admins << admin
      end
    end

  end
end
