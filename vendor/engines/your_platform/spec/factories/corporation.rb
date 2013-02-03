FactoryGirl.define do

  factory :corporation, :class => "Corporation" do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "The Corporation of #{token.to_s}" }
    sequence( :extensive_name ) { |n| "The Great Corporation of the #{token.to_s}" }
    sequence( :internal_token ) { |n| "#{token.to_s}C" }

    after( :create ) do |corporation|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_corporations_parent_group unless Group.find_corporations_parent_group
      Group.corporations << corporation
    end

  end

end

