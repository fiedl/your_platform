FactoryGirl.define do
   factory :user do
      sequence( :first_name ) { |n| "Max" }
      last_name  "Mustermann" 
      sequence( :alias ) { "m.mustermann" }
      email      "max.mustermann@example.com" 
      create_account true
   end
end
