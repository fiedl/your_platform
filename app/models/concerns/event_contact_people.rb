concern :EventContactPeople do

  included do
    attr_accessor :contact_person_id
    after_save :assign_contact_person_given_by_contact_person_id
  end

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
    contact_people_group.members
  end

  def destroy
    find_contact_people_group.try(:destroy)
    super
  end

  def assign_contact_person_given_by_contact_person_id
    # Assign the contact person in a background job to save some time here.
    Event.delay.assign_contact_person_to_event self.id, contact_person_id if contact_person_id
  end

  def self.assign_contact_person_to_event(event_id, contact_person_id)
    Event.find(event_id).contact_people_group << User.find(contact_person_id)
  end

end