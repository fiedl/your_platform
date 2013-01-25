FactoryGirl.define do

  factory :corporation do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "The Corporation of #{token}" }
    sequence( :extensive_name ) { |n| "The Great Corporation of the #{token}" }
    sequence( :internal_token ) { |n| "#{token}C" }

    after( :create ) do |corporation|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_corporations_parent_group unless Group.find_corporations_parent_group
      Group.corporations << corporation
    end

    factory :corporation_with_status_groups do
      after :create do |corporation|
        corporation.child_groups.create( name: "Member Status 1" )
        corporation.child_groups.create( name: "Member Status 2" )
        corporation.child_groups.create( name: "Member Status 3" )
      end
    end

  end

end

