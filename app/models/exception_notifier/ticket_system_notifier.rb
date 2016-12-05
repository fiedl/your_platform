module ExceptionNotifier
  class TicketSystemNotifier < EmailNotifier

    def initialize(options)
      @fallback_sender_address = options[:fallback_sender_address]
      options[:sender_address] ||= options[:fallback_sender_address]
      super(options)
    end

    def call(exception, options = {})
      options[:env] ||= {}
      options[:env]['exception_notifier.exception_data'] ||= {}
      options[:env]['exception_notifier.exception_data'][:backtrace] = exception.backtrace
      if current_user = options[:env]['exception_notifier.exception_data'][:current_user]
        options[:sender_address] = "#{current_user.title} <#{current_user.email}>"
      end
      super(exception, options)
    end

  end
end