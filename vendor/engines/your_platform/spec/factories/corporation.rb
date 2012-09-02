FactoryGirl.define do

  factory :corporation, :class => "Group" do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "The Corporation of #{token}" }
    sequence( :extensive_name ) { |n| "The Great Corporation of the #{token}" }
    sequence( :internal_token ) { |n| "#{token}C" }

    after( :create ) do |corporation|
      raise 'no corporations parent group' unless Group.find_corporations_parent
      Group.find_corporations_parent.child_groups << corporation
    end

  end

end

