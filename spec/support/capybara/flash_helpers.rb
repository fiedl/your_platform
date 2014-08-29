module FlashHelpers

  def has_notice?(message)
    has_selector?('div.alert.alert-info', :text => message)
  end

  def has_error_message?(message)
    has_selector?('div.alert.alert-danger', :text => message)
  end

  def has_warning?(message)
    has_selector?('div.alert.alert-warning', :text => message)
  end

  def has_validation_errors?
    has_selector?('.field_with_errors')
  end

end

Capybara::Session.send(:include, FlashHelpers)
