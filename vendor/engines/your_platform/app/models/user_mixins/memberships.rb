# 
# This module contains the methods of the User model regarding the associated 
# user group memberships and groups.
#
module UserMixins::Memberships
  
  extend ActiveSupport::Concern
  
  # TODO: Refactor conditions to rails 4 standard when migrating to rails 4.
  # See, for example, https://github.com/fiedl/neo4j_ancestry/blob/master/lib/models/neo4j_ancestry/active_record_additions.rb#L117.
  
  included do
    
    # User Group Memberships
    # ==========================================================================================
    
    # This associates all UserGroupMembership objects of the group, including indirect 
    # memberships.
    #
    has_many( :memberships, 
              class_name: 'UserGroupMembership',
              foreign_key: :descendant_id, conditions: { ancestor_type: 'Group', descendant_type: 'User' } )
    
    # This associates all memberships of the group that are direct, i.e. direct 
    # parent_group-child_user memberships.
    #
    has_many( :direct_memberships,
              class_name: 'UserGroupMembership', 
              foreign_key: :descendant_id, conditions: { ancestor_type: 'Group', descendant_type: 'User', direct: true } )
              
    # This associates all memberships of the group that are indirect, i.e. 
    # ancestor_group-descendant_user memberships, where groups are between the
    # ancestor_group and the descendant_user.
    #
    has_many( :indirect_memberships,
              class_name: 'UserGroupMembership', 
              foreign_key: :descendant_id, conditions: { ancestor_type: 'Group', descendant_type: 'User', direct: false } )
    
    
    # This returns the membership of the user in the given group if existant.
    #
    def membership_in( group )
      memberships.where(ancestor_id: group.id).limit(1).first
    end
    
    # This returns whether the user is a member of the given group, direct or indirect.
    #
    def member_of?( group )
      groups.include? group
    end
    
    
    # Groups the user is member of
    # ==========================================================================================

    # This associates the groups the user is member of, direct as well as indirect.
    #
    has_many(:groups, 
      through: :memberships,
      source: :ancestor, source_type: 'Group', :uniq => true,
      conditions: { 'dag_links.descendant_type' => 'User' }
      )

    # This associates only the direct groups.
    #
    has_many(:direct_groups, 
      through: :direct_memberships, 
      source: :ancestor, source_type: 'Group', :uniq => true,
      conditions: { 'dag_links.descendant_type' => 'User', 'dag_links.direct' => true }
      )
    
    # This associates only the indirect groups.
    #
    has_many(:indirect_groups, 
      through: :indirect_memberships, 
      source: :ancestor, source_type: 'Group', :uniq => true,
      conditions: { 'dag_links.descendant_type' => 'User', 'dag_links.direct' => false }
      )
    
  end
end
