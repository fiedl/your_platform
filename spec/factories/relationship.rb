FactoryGirl.define do

  # relationship
  #
  factory :relationship do

    association :who, factory: :user
    is "Brother"
    association :of, factory: :user

  end

end
