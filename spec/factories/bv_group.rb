FactoryGirl.define do

  factory :bv_group, :class => "Bv" do
    
    sequence( :token ) { |n| "BV#{n}" }
    sequence( :name ) { |n| "#{token}" }
    sequence( :extensive_name ) { |n| "Bezirksverband #{n}" }
    sequence( :internal_token ) { |n| "#{token}" }

    after( :create ) do |bv|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_bvs_parent_group unless Group.find_bvs_parent_group
      Group.bvs << bv
    end


  end

end
