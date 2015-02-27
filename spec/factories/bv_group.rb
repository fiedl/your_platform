FactoryGirl.define do

  factory :bv_group, aliases: [:bv], :class => "Bv" do
    
    before(:create) do
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_bvs_parent_group unless Group.find_bvs_parent_group
    end      
    
    sequence( :token ) { |n| "BV#{n}" }
    sequence( :name ) { |n| "#{token}" }
    sequence( :extensive_name ) { |n| "Bezirksverband #{n}" }
    sequence( :internal_token ) { |n| "#{token}" }

    after( :create ) do |bv|
      # TODO: Check if this can be removed in rails 4 due to the scope.
      # I.e. is the scope automatically applied correctly to newly created elements?
      #
      Group.bvs << bv
    end


  end

end
