concern :MembershipPersistence do

  # Direct memberships are stored as DagLinks in the database.
  # This is, because we've used the acts_as_dag gem earlier:
  # https://github.com/resgraph/acts-as-dag
  # 
  # In contrast to the gem, we do not store indirect links
  # in the database anymore, since this makes write operations
  # too expensive for large graphs.
  #
  def dag_link
    @dag_link ||= DagLink.where(ancestor_type: 'Group', descendant_type: 'User', direct: true,
      ancestor_id: group.id, descendant_id: user.id).first
  end
  
  def id
    dag_link.try(:id)
  end

  def persisted?
    dag_link.try(:persisted?) || false
  end
  
  def save
    write_attributes_to_dag_link
    dag_link.save
  end
  
  def save!
    raise 'Cannot save! Indirect memberships are non-persistent objects.' unless direct?
    write_attributes_to_dag_link
    dag_link.changed? ? dag_link.save! : true
  end
  
  def update_attributes!(attrs = {})
    set_attributes(attrs)
    save!
  end
  
  def update_attributes(attrs = {})
    set_attributes(attrs)
    save if direct?
  end
  
  def reload
    @dag_link = nil
    @valid_from = dag_link.valid_from
    @valid_to = dag_link.valid_to
    return self
  end

  delegate :destroyed?, :new_record?, to: :dag_link
  
  def destroyable?
    direct? && dag_link.destroyable?
  end
  
  def destroy
    (destroyable? && dag_link.try(:destroy)) || raise("could not destroy membership #{id}.")
  end
  
  def _read_attribute(key)
    send(key) if key.in? [:valid_from, :valid_to]
  end

  private
  
  def write_attributes_to_dag_link
    dag_link.valid_from = @valid_from
    dag_link.valid_to = @valid_to
    dag_link.ancestor_id = @group.id
    dag_link.descendant_id = @user.id
  end

  def set_attributes(attrs)
    attrs.each do |key, value|
      send("#{key}=", value)
    end
  end
  
  
  class_methods do
    def base_class
      Membership
    end

    def primary_key
      :id
    end
    
    def build(params)
      group_id = params[:group_id] || params[:group].try(:id)
      user_id = params[:user_id] || params[:user].try(:id)
      Membership.new(dag_link: DagLink.new(ancestor_type: 'Group', ancestor_id: group_id, descendant_type: 'User', descendant_id: user_id))
    end
  end

end