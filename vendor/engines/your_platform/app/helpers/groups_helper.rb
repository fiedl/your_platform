module GroupsHelper
  
  def groups_of_user_table( user )
    content_tag :table, :class => "user_groups" do
      content_tag :tr do
        
        # first column:
        c = content_tag :td do
          content_tag :ul do
            
            corporation_groups = user.cached_current_corporations
            if corporation_groups
              corporation_groups.collect do |group|
                sub_group_membership_lis( user: user, group: group, indent: 0, max_indent: 3 )
              end.join.html_safe
            end
            
          end
        end

        # second column:
        c += content_tag( :td ) do
          content_tag :ul do
            
            Group.find_non_corporations_branch_groups_of( user ).collect do |group|
              membership_li( user, group )
            end.join.html_safe
            
          end
        end
      end
    end.html_safe
  end
  
  private

  def membership_li( user, group )
    content_tag :li do
      c = link_to group.title, group
      membership = UserGroupMembership.with_invalid.find_by_user_and_group( user, group )
      c += remove_button( membership ) if membership.destroyable? and can?(:destroy, membership)
      c
    end
  end

  def sub_group_membership_lis( options = {} )
    c = ""
    c += membership_li( options[ :user ], options[ :group ] )
    sub_groups_where_user_is_member = options[ :group ].child_groups & options[ :user ].groups
    current_indent = options[ :indent ] + 1
    max_indent = options[ :max_indent ]
    current_indent = max_indent if current_indent > max_indent
    c += "<ul>" if current_indent < max_indent
    c += sub_groups_where_user_is_member.collect do |sub_group|
      sub_group_membership_lis( user: options[ :user ], group: sub_group, 
                                indent: current_indent, max_indent: options[ :max_indent ] )
    end.join
    c += "</ul>" if current_indent < max_indent
    return c.html_safe
  end

end
