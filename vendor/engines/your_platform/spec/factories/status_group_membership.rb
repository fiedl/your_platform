FactoryGirl.define do

  # status group membership
  #
  factory :status_group_membership do

    initialize_with do
      @user = create( :user )
      @group = create( :group )
      StatusGroupMembership.create( user: @user, group: @group )
    end

    updated_at DateTime.now

  end

end
