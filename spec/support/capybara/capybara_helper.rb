module CapybaraHelper
  # See also: https://github.com/jnicklas/capybara/blob/master/lib/capybara/node/actions.rb

  def t(*args)
    if I18n.exists?(args.first)
      I18n.translate(*args)
    else
      args.last.try(:[], :default) || args.first
    end
  end

  def click_on(link_text)
    if link_text.kind_of?(String) or link_text.kind_of?(Symbol)
      super(t(link_text, default: link_text))
    else # It could already be a node.
      super link_text
    end
  end

  def check(label_text, options = {})
    find(:checkbox, t(label_text, default: label_text), options).set(true) if poltergeist?
    super(t(label_text, default: label_text), options)
  end

  def uncheck(label_text, options = {})
    find(:checkbox, t(label_text, default: label_text), options).set(false) if poltergeist?
    super(t(label_text, default: label_text), options)
  end

  def selenium?
    Capybara.current_driver == :selenium
  end

  def poltergeist?
    Capybara.current_driver == :poltergeist
  end

  def give_it_some_time_to_finish_the_test_before_wiping_the_database
    # This is applied to all js specs by a `config.after` hook in the
    # spec helper.
    #
    # Otherwise, the database would be cleaned before the capybara
    # test has finished. This is because the server runs parallel to
    # the test itself.
    #
    # See also: https://github.com/jnicklas/capybara/issues/1089
    #
    wait_for_ajax
  end

  # Example:
  #   select_in_place "#layout", "bootstrap"
  #
  def select_in_place(selector, option)
    find_best_in_place(selector).click
    # select option, from: selector
    # http://stackoverflow.com/a/20134451/2066546
    find_best_in_place(selector).find('select').find(:option, option).select_option
  end

  def enter_in_place(selector, text)
    enter_in_place_with_pressing_enter(selector, text)
  end

  def enter_in_place_with_pressing_enter(selector, text)
    enter_in_place_without_pressing_enter(selector, "#{text}\n")
  end

  def enter_in_place_without_pressing_enter(selector, text)
    find_best_in_place(selector).click
    find_best_in_place(selector).find('input').set(text)
  end

  def enter_in_edit_mode(selector, text)
    enter_in_place_without_pressing_enter(selector, text)
  end

  def find_best_in_place(selector)
    if selector.include? ".best_in_place"
      find(selector)
    else
      find(selector).find(".best_in_place")
    end
  end

  def drop_attachment_in_drop_field(filename = 'pdf-upload.pdf')
    local_file_path = File.expand_path(File.join(__FILE__, "../../../support/uploads/#{filename}"))
    File.exist?(local_file_path).should == true
    find('#attachment_file', visible: false).set local_file_path
  end

end

# https://github.com/ryanb/cancan/blob/master/lib/cancan/matchers.rb
RSpec::Matchers.define :be_able_to do |*args|
  match do |ability|
    ability.can?(*args)
  end

  failure_message_for_should do |ability|
    "expected to be able to #{args.map(&:inspect).join(" ")}"
  end

  failure_message_for_should_not do |ability|
    "expected not to be able to #{args.map(&:inspect).join(" ")}"
  end
end
