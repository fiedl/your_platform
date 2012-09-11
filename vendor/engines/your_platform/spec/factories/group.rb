FactoryGirl.define do

  factory :group do
  
    sequence( :name ) { |n| "Group #{n}" }
    sequence( :token ) { |n| "G#{n}" }
    sequence( :extensive_name ) { |n| "The Group #{n}" }
    sequence( :internal_token ) { |n| "#{n}G" }

  end

end

