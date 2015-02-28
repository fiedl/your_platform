FactoryGirl.define do

  factory :page do
    
    sequence( :title ) { |n| "Page #{n}" }
    content "This is some <strong>example content</strong>."

  end

end
