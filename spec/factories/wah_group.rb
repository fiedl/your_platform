FactoryGirl.define do

  factory :wah_group, :class => "Wah" do
    
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "#{token}er Wingolf" }
    sequence( :extensive_name ) { |n| "#{token}er Wingolf" }
    sequence( :internal_token ) { |n| "#{token}W" }

    after( :create ) do |corporation|
      raise 'no corporations parent group' unless Group.corporations_parent
      Group.corporations_parent.child_groups << corporation
      corporation.child_groups.create( name: "Aktivitas" )
      corporation.child_groups.create( name: "Philisterschaft" )
    end


  end

end
