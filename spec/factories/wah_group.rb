FactoryGirl.define do

  factory :wah_group, :class => "Corporation" do
    
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "#{token}er Wingolf" }
    sequence( :extensive_name ) { |n| "#{token}er Wingolf" }
    sequence( :internal_token ) { |n| "#{token}W" }

    after( :create ) do |corporation|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_corporations_parent_group unless Group.find_corporations_parent_group
      Group.corporations << corporation
      corporation.child_groups.create( name: "Aktivitas" )
      corporation.child_groups.create( name: "Philisterschaft" )
    end


  end

end
