class Event < ActiveRecord::Base
  attr_accessible :description, :location, :end_at, :name, :start_at, :localized_start_at, :localized_end_at

  is_structureable ancestor_class_names: %w(Group), descendant_class_names: %w(Group)
  is_navable

  
  # General Properties
  # ==========================================================================================

  # The title, i.e. the caption of the event is its name.
  def title
    name
  end


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
  
  # Times
  # ==========================================================================================
  
  def localized_start_at
    I18n.localize start_at.to_time if start_at.present?
  end
  def localized_start_at=(string)
    attribute_will_change! :start_at
    #self.start_at = string.present? ? Time.parse(string) : nil
    self.start_at = string  # conversion handled by the delocalize gem
  end
  
  def localized_end_at
    I18n.localize end_at.to_time if end_at.present?
  end
  def localized_end_at=(string)
    attribute_will_change! :end_at
    #self.end_at = string.present? ? Time.parse(string) : nil
    self.end_at = string  # conversion handled by the delocalize gem
  end
  


  # Contact People and Attendees
  # ==========================================================================================
  
  def find_contact_people_group
    find_special_group :contact_people
  end
  def create_contact_people_group
    create_special_group :contact_people
  end
  def contact_people_group
    find_contact_people_group || create_contact_people_group
  end
  def contact_people
    contact_people_group.child_users
  end
  
  def find_attendees_group
    find_special_group :attendees
  end
  def create_attendees_group
    create_special_group :attendees
  end
  def attendees_group
    find_attendees_group || create_attendees_group
  end
  def attendees
    attendees_group.child_users
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
                :ancestor_type => "Group", :ancestor_id => ancestor_id
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
