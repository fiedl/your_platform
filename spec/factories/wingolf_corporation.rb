FactoryGirl.define do

  factory :wingolf_corporation, :class => "Corporation" do
  
    sequence( :token ) { |n| ( "A".."Z" ).to_a[ n ] }
    sequence( :name ) { |n| "#{token.to_s}er Wingolf" }
    sequence( :extensive_name ) { |n| "#{token.to_s}er Wingolf" }
    sequence( :internal_token ) { |n| "#{token.to_s}W" }

    after( :create ) do |corporation|
      Group.create_everyone_group unless Group.find_everyone_group
      Group.create_corporations_parent_group unless Group.find_corporations_parent_group
      Group.corporations << corporation
      
      corporation.import_default_group_structure "default_group_sub_structures/wingolf_am_hochschulort_children.yml"
      corporation.reload
      
      Group.alle_aktiven << corporation.child_groups.where(name: 'Aktivitas').first
      Group.alle_philister << corporation.child_groups.where(name: 'Philisterschaft').first
    end
  end
end

