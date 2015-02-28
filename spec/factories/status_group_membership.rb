FactoryGirl.define do

  # status group membership
  #
  factory :status_group_membership do

    initialize_with do
      @user = create( :user )
      @group = create( :group )
      StatusGroupMembership.create( user: @user, group: @group )
    end

    # This is needed, since the above attributes are delegated and therefore
    # the creation will raise a 'no changes' error unless something is
    # touched here.
    #
    updated_at DateTime.now

  end

end
