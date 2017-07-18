# Issues are things admins need to take a look at and resolve them.
# For example: Missing emails, implausible postal addresses etc.
#
# ## Usage
#
#     Issue.scan            # Perform an overall scan for issues.
#     Issue.scan(object)    # Scan a specific object for issues.
#     Issue.scan(objects)   # Scan multiple objects.
#
#     Issue.unresolved      # Scope that detects only unresolved issues.
#
#     issues = Issue.scan
#     issue = issues.first
#     issue.resecan         # Rescan a specific issue.
#
class Issue < ApplicationRecord

  belongs_to :reference, polymorphic: true
  belongs_to :responsible_admin, class_name: 'User', optional: true
  belongs_to :author, class_name: 'User', optional: true

  scope :unresolved, -> { where(resolved_at: nil) }
  scope :by_admin, ->(admin) { where(responsible_admin_id: admin.id) }
  scope :automatically_created, -> { where author_id: nil }

  scope :concerning_postal_addresses, -> {
    ids = all.select { |issue| issue.reference.kind_of? ProfileFields::Address }.map(&:id)
    where(id: ids)
  }

  def self.scan(object_or_objects = nil)
    if object_or_objects && object_or_objects.respond_to?(:to_a)
      self.scan_objects(object_or_objects)
    elsif object_or_objects.present?
      self.scan_object(object_or_objects)
    else
      self.scan_all
    end
  end
  def self.scan_objects(objects)
    objects.collect { |obj| self.scan_object(obj) }.flatten - [nil]
  end
  def self.scan_object(object)
    return self.scan_address_field(object) if object.kind_of? ProfileFields::Address
    return self.scan_email_field(object) if object.kind_of? ProfileFields::Email
    return self.scan_membership(object) if object.kind_of? Membership
  end
  def self.scan_all
    self.scan_objects(ProfileFields::Address.all) +
    self.scan_objects(ProfileFields::Email.all) +
    self.scan_objects(Membership.find_all.direct)
  end

  def self.scan_address_field(address_field)
    address_field.issues.destroy_auto
    if address_field.postal_or_first_address?
      if address_field.value.to_s.split("\n").count < 2
        address_field.issues.create title: 'issues.address_has_too_few_lines', description: 'issues.address_needs_between_2_and_4_lines', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      elsif address_field.value.to_s.split("\n").count > 4
        address_field.issues.create title: 'issues.address_has_too_many_lines', description: 'issues.address_needs_between_2_and_4_lines', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      end
      if address_field.country_code == "A" and not (address_field.value.include?("Österreich") or address_field.value.include?("Austria"))
        address_field.issues.create title: 'issues.destination_country_is_missing', description: 'issues.the_destination_country_has_to_be_the_last_line', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      end
      if address_field.try(:street_with_number).try(:strip).blank? && address_field.value.try(:strip).present? && address_field.value.to_s.split("\n").count > 1
        address_field.issues.create title: 'issues.could_not_extract_street', description: 'issues.the_geo_system_could_not_extract_the_street_from_this_address', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      end
    end
    return address_field.issues(true)
  end

  def self.scan_email_field(email_field)
    email_field.issues.destroy_auto
    if email_field.value.try(:present?) && PostDelivery.where(user_email: email_field.value, created_at: 3.weeks.ago..Time.zone.now).failed.count > 0
      email_field.issues.create title: 'issues.could_not_deliver_to_email', description: 'issues.please_enter_the_correct_email_address', responsible_admin_id: email_field.profileable.try(:responsible_admin_id)
    elsif email_field.value.present? && email_field.needs_review?
      email_field.issues.create title: 'issues.email_needs_review', description: 'issues.please_enter_the_correct_email_address', responsible_admin_id: email_field.profileable.try(:responsible_admin_id)
    end
    return email_field.issues(true)
  end

  def self.scan_membership(membership)
    membership.issues.destroy_auto
    if membership.valid_from && membership.valid_from.year < 1700
      membership.issues.create title: 'issues.membership_valid_from_too_small', description: 'issues.please_check_membership_validity_range', responsible_admin_id: membership.user.try(:responsible_admin_id)
    elsif membership.valid_to && membership.valid_to.year < 1700
      membership.issues.create title: 'issues.membership_valid_to_too_small', description: 'issues.please_check_membership_validity_range', responsible_admin_id: membership.user.try(:responsible_admin_id)
    elsif membership.valid_from && membership.valid_to && membership.valid_from > membership.valid_to
      membership.issues.create title: 'issues.membership_valid_to_before_valid_from', description: 'issues.please_check_membership_validity_range', responsible_admin_id: membership.user.try(:responsible_admin_id)
    end
  end

  # Notify responsible admins if there are open issues.
  #
  def self.notify_admins
    Issue.unresolved.pluck(:responsible_admin_id).uniq.collect do |admin_id|
      admin = User.find admin_id
      issues = Issue.unresolved.by_admin(admin)
      issues_url = "#{AppVersion.root_url}/issues"
      I18n.with_locale(admin.locale) do
        message = I18n.t(:there_are_n_unresolved_issues_in_your_domain, n: issues.count)
        text = I18n.t(:please_click_above_link_and_resolve_issues)
        notification = Notification.create recipient_id: admin_id, reference_url: issues_url, message: message, text: text
      end
    end
  end

  def reference
    ref = super
    if ref.kind_of? DagLink
      if ref.ancestor_type == "Group" and ref.descendant_type == "User"
        ref.becomes(Membership)
      else
        ref
      end
    else
      ref
    end
  end

  def reference_content
    return reference.value if reference.kind_of?(ProfileField)
  end

  def resolve
    self.resolved_at = Time.zone.now
    self.save
  end

  def self.destroy_auto
    self.destroy_automatically_created
  end
  def self.destroy_automatically_created
    self.automatically_created.destroy_all
  end

end
