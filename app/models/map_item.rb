class MapItem

  attr_accessor :object
  attr_accessor :title
  attr_accessor :address, :phone, :email, :website
  attr_accessor :image_url, :image_link_url
  attr_accessor :longitude, :latitude

  def initialize(object)
    @object = object
  end

  def address_field
    @address_field ||= object.primary_address_field
  end

  def title
    @title ||= object.title
  end

  def title_link_url
    website
  end

  def address
    @address ||= address_field.try(:value)
  end

  def phone
    @phone ||= object.phone_field.try(:value)
  end

  def email
    @email ||= object.email
  end

  def website
    @website ||= object.website
  end

  def image_attachments
    object.descendant_pages.collect { |page| page.image_attachments }.flatten
  end

  def image_url
    @image_url ||= image_attachments.first.try(:big_url)
  end

  def image_link_url
    website
  end

  def longitude
    @longitude ||= address_field.try(:longitude)
  end

  def latitude
    @latitude ||= address_field.try(:latitude)
  end

  def to_hash
    {
      title: title,
      title_link_url: title_link_url,
      address: address,
      phone: phone,
      #email: email,  #  Do not include the email here until we have something to avoid spam crawlers (TODO).
      website: website,
      image_url: image_url,
      image_link_url: image_link_url,
      longitude: longitude,
      latitude: latitude
    }
  end

  def self.from_group(group)
    map_item = self.new(group)
    map_item.address
    map_item.phone
    map_item.email
    map_item.website
    map_item.image_url
    map_item.image_link_url
    map_item.longitude
    map_item.latitude
    map_item
  end

  def self.from_groups(groups_or_parent_group)
    groups = groups_or_parent_group.kind_of?(Group) ? ([groups_or_parent_group] + groups_or_parent_group.child_groups) : groups_or_parent_group
    groups.collect(&:map_item)
  end

  def self.from_corporations(corporations = nil)
    corporations ||= Corporation.all
    corporations.collect(&:map_item)
  end

end