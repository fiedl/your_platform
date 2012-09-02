FactoryGirl.define do

  factory :bv_group, :class => "Bv" do
    
    sequence( :token ) { |n| "BV#{n}" }
    sequence( :name ) { |n| "#{token}" }
    sequence( :extensive_name ) { |n| "Bezirksverband #{n}" }
    sequence( :internal_token ) { |n| "#{token}" }

    after( :create ) do |bv|
      raise 'no bvs parent group' unless Group.find_bvs_parent
      Group.find_bvs_parent.child_groups << bv
    end


  end

end
