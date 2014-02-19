FactoryGirl.define do

  factory :group do
  
    sequence( :name ) { |n| "Group #{n}" }
    sequence( :token ) { |n| "G#{n}" }
    sequence( :extensive_name ) { |n| "The Group #{n}" }
    sequence( :internal_token ) { |n| "#{n}G" }


    trait :with_users do
      after :create do |group|
        10.times do
          user = create(:user, :with_address)
          group.child_users << user
        end
      end
    end


    trait :with_hidden_user do
      after :create do |group|
        user = create(:user, :with_address, :hidden, last_name: 'Hidden')
        group.child_users << user
      end
    end

    trait :with_dead_user do
      after :create do |group|
        user = create(:user, :with_address, :dead, last_name: 'Dead')
        group.child_users << user
      end
    end

  end

end

