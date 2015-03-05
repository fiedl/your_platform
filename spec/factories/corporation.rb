FactoryGirl.define do

  factory :corporation do
    sequence(:token) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence(:name) { |n| "The Corporation of #{token.to_s}" }
    sequence(:extensive_name) { |n| "The Great Corporation of the #{token.to_s}" }
    sequence(:internal_token) { |n| "#{token.to_s}C" }

    factory :corporation_with_status_groups do
      after :create do |corporation|
        status1 = corporation.child_groups.create(name: "Member Status 1")
        status2 = corporation.child_groups.create(name: "Member Status 2")
        status3 = corporation.child_groups.create(name: "Member Status 3")
        [status1, status2, status3].each { |g| g.add_flag :full_members } # in contrast to deceased
      end
    end
  end

end

