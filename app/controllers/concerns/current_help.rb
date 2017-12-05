concern :CurrentHelp do

  included do
    helper_method :current_help_topics
  end

  def set_current_help_topic(topic)
    @current_help_topic = t(topic, default: topic)
  end

  def current_help_topics
    [@current_help_topic] - [nil]
  end

  class_methods do
    def help_topic(topic)
      before_action { set_current_help_topic(topic) }
    end
  end

end