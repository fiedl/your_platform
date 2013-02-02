module CorporateVitaHelper

  def corporate_vita_for_user( user )
    render partial: 'users/corporate_vita', locals: { 
      user: @user,
    } 
  end

  def status_group_memberships_for_user_and_corporation( user, corporation )
    StatusGroupMembership
      .find_all_by_user_and_corporation( user, corporation )
      .now_and_in_the_past
  end

  def status_group_membership_created_at_best_in_place( membership )
    best_in_place( membership,
                   :created_at,
                   type: :date,
                   display_with: lambda { |v| l( v.to_date ) },
                   path: user_group_membership_path( user_id: membership.user.id,
                                                     group_id: membership.group.id,
                                                     controller: :user_group_memberships,
                                                     action: :update,
                                                     format: :json
                                                     )
                   )
  end

end
