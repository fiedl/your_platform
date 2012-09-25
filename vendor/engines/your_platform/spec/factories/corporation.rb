FactoryGirl.define do

  factory :corporation do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "The Corporation of #{token}" }
    sequence( :extensive_name ) { |n| "The Great Corporation of the #{token}" }
    sequence( :internal_token ) { |n| "#{token}C" }

    after( :create ) do |corporation|
      raise 'no corporations parent group' unless Group.find_corporations_parent_group
      Group.corporations << corporation
    end

  end

end

