FactoryGirl.define do

  factory :blog_post do
    
    sequence( :title ) { |n| "Blog Post #{n}" }
    content "This is some <strong>example content</strong>."

  end

end
