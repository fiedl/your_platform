class TestWorker
  include Sidekiq::Worker

  def perform(user_params)

    $enable_tracing = false
    $trace_out = open('trace.txt', 'w')

    set_trace_func proc { |event, file, line, id, binding, classname|
      if $enable_tracing && event == 'call'
        $trace_out.puts "#{file}:#{line} #{classname}##{id}"
      end
    }

    $enable_tracing = true
    
    Sidekiq::Logging.logger = nil

    
    p "START"

    user = User.create!(user_params)

    p "uncached ..."
    user.uncached(:name)

    p "cached ..."
    user.cached(:name)

    p "SUCCESS"
  end

end