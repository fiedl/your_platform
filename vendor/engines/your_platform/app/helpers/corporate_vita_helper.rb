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
                   :created_at_date_formatted,
                   type: :date,
                   path: user_group_membership_path( user_id: membership.user.id,
                                                     group_id: membership.group.id,
                                                     controller: :user_group_memberships,
                                                     action: :update,
                                                     format: :json
                                                     ),
                   :classes => "status_group_date_of_joining"
                   )
  end
  
  def status_group_membership_promoted_on_event( membership )
    event = membership.event
    if event
      link_to membership.event.name, membership.event, :class => 'status_event_label'
    else
      best_in_place( membership,
                     :event_by_name,
                     path: status_group_membership_path( membership )
                     )
    end
  end


end
