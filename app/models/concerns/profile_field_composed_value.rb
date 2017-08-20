concern :ProfileFieldComposedValue do

  included do
    before_save :adapt_composed_value
    after_save :save_parent_composed_value
  end

  # If the field has children, their values are included in the main field's value.
  # Attention! Probably, you want to display only one in the view: The main value or the child fields.
  #
  def composed_value
    if children_count > 0
      children.collect { |child| child.value }.join(", ")
    else
      read_attribute :value
    end
  end

  # The profile field's value is stored in the database.
  #
  # But right after saving several child profile fields through the ui, there are
  # concurrency issues. Therefore, fall back to the calculated `composed_value` during
  # the first couple of seconds.
  #
  def value
    return super if updated_at && (updated_at < 5.seconds.ago)
    return super if children.none?

    # Recalculate the value and store it.
    v = composed_value
    write_attribute :value, v if v != read_attribute(:value)
    return v
  end

  def save_parent_composed_value
    if self.value_changed? && (! @do_not_save_parent) && self.parent && self.parent.reload && self.parent.children.reload && (self.parent.value != (composed_value = self.parent.composed_value))
      self.parent.update_attributes value: composed_value
      @do_not_save_parent = false
    end
  end
  def do_not_save_parent
    @do_not_save_parent = true
  end

  def adapt_composed_value
    self.value = self.composed_value if children.any?
  end

end