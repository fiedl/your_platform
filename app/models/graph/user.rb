class Graph::User < Graph::Node

  def user
    @object
  end

  def node_label
    "User"
  end

  def properties
    {id: user.id, name: user.name.to_s, title: user.title.to_s, first_name: user.first_name.to_s, last_name: user.last_name.to_s, name_affix: user.name_affix.to_s}
  end

  def page_ids_of_pages_the_user_is_page_officer_of
    query_ids("
      match (user:User:#{namespace} {id: #{user.id}})<-[m:MEMBERSHIP]-(:Group {type: 'OfficerGroup'})<-[:HAS_SUBGROUP*0..5]-(:Group {type: 'OfficerGroup'})<--(officers_parent:Group)<--(scope:Page)-[:HAS_SUBPAGE*]->(subpages:Page)
      where not (subpages)<-[*]-(:Page {flags: 'intranet_root'})
      and #{Graph::Membership.validity_range_condition}
      return scope.id, subpages.id
    ").uniq
  end

end