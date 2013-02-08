class Event < ActiveRecord::Base
  attr_accessible :description, :end_at, :name, :start_at

  is_structureable ancestor_class_names: %w(Group), descendant_class_names: %w(Group)

  # Groups
  # ==========================================================================================

  # Eeach event is assigned to zero,  one or several groups.
  # Internally, this is modelled using the DAG structure, i.e. one can use
  # the `event.parent_groups` association.
  # But for convenience, here are a few more accessor methods:

  def group
    self.parent_groups.first
  end
  def group=( group )
    self.destroy_dag_links
    self.parent_groups << group
  end
  def groups
    self.parent_groups
  end

  # Scopes
  # ==========================================================================================

  scope :upcoming, lambda { where( "start_at > ?", Time.zone.now ) }

  scope :direct, lambda { includes( :links_as_descendant ).where( :dag_links => { :direct => true } ) }

  def upcoming?
    ( self.start_at > Time.zone.now )
  end

  # Finder Methods
  # ==========================================================================================

  def self.find_all_by_group( group )
    ancestor_id = group.id if group
    self.includes( :links_as_descendant )
      .where( :dag_links => { 
                :ancestor_type => "Group", :ancestor_id => ancestor_id, 
              } )
      .order( :start_at )
  end

  def self.find_all_by_groups( groups )
    group_ids = groups.collect { |g| g.id }
    self.includes( :links_as_descendant )
      .where( :dag_links => { 
                :ancestor_type => "Group", :ancestor_id => group_ids
              } )
      .order( :start_at )
  end 

end
