FactoryGirl.define do

  factory :event do
  
    sequence( :name ) { |n| "Event #{n}" }
    description "This is some Description."
    start_at 1.hours.from_now
    end_at 4.hours.from_now

  end

end

