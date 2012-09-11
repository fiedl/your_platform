FactoryGirl.define do

  factory :bv_group, :class => "Bv" do
    
    sequence( :token ) { |n| "BV#{n}" }
    sequence( :name ) { |n| "#{token}" }
    sequence( :extensive_name ) { |n| "Bezirksverband #{n}" }
    sequence( :internal_token ) { |n| "#{token}" }

    after( :create ) do |bv|
      raise 'no bvs parent group' unless Group.bvs_parent
      Group.bvs << bv
    end


  end

end
