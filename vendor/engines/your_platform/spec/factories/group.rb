FactoryGirl.define do

  factory :group do
  
    sequence( :name ) { |n| "Group #{n}" }
    sequence( :token ) { |n| "G#{n}" }
    sequence( :extensive_name ) { |n| "The Group #{n}" }
    sequence( :internal_token ) { |n| "#{n}G" }


    trait :with_users do
      after :create do |group|
        10.times do
          user = create(:user)
          group.child_users << user
        end
      end
    end


    trait :with_hidden_user do
      after :create do |group|
        user = create(:user, :hidden, last_name: 'Hidden')
        group.child_users << user
      end
    end

  end

end

