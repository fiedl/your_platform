concern :Review do

  included do
    raise RuntimeError, 'missing `include Flags`.' unless self.instance_methods.include? :flags

    scope :review_needed, -> { joins(:flags).where('flags.key' => :needs_review, 'flags.flagable_type' => 'ProfileField') }

    # Use this scope, for example, to find all emails that do not reed review.
    # Those are usable in email notifications.
    #
    #     ProfileFields::Email.no_review_needed
    #
    scope :no_review_needed, -> { where.not(id: self.review_needed.pluck(:id)) }

    after_update -> {
      # Mark as reviewd on chaning the field.
      self.remove_flag :needs_review if changed?
    }
  end

  class_methods do

    # This class method gets all ProfileFields that are marked as :needs_review.
    #
    def find_all_that_need_review
      self.review_needed
    end

    # This class method gets all ProfileFields that match the given ids
    # and are marked as :needs_review.
    #
    def find_all_that_need_review_by_profile_field_ids(profile_field_ids)
      self.find_all_that_need_review.where(id: profile_field_ids)
    end

  end

  def needs_review?
    has_flag? :needs_review
  end
  def needs_review!
    self.needs_review = true
  end
  def needs_review
    self.needs_review?
  end
  def needs_review=(new_needs_review)
    new_needs_review = false if new_needs_review == "false"
    if new_needs_review != self.needs_review
      attribute_will_change!(:needs_review)
    end
    if new_needs_review
      self.add_flag :needs_review
    else
      self.remove_flag :needs_review
    end
  end

end