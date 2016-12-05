module WaitForAjax

  # # http://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
  #
  # def wait_for_ajax
  #   Timeout.timeout(Capybara.default_max_wait_time) do
  #     loop until finished_all_ajax_requests?
  #   end
  # end
  #
  # def finished_all_ajax_requests?
  #   page.evaluate_script('jQuery.active').zero?
  # end

  def wait_for_ajax
    sleep(wait_time * 1.5)
  end

  # def wait_for_ajax
  #   Timeout.timeout(Capybara.default_max_wait_time) do
  #     loop until finished_all_ajax_requests?
  #   end
  # end

  def wait_time
    @wait_time ||= wait_time_from_benchmark
  end

  def wait_time_from_benchmark
    n = 4000000  # which corresponds roughly to 1.3 second locally for my system.
    elapsed_time do
      for i in 1..n
        a = "1"
      end
    end
  end

  def elapsed_time(&block)
    t1 = Time.zone.now
    yield(block)
    t2 = Time.zone.now
    (t2 - t1).seconds
  end

  # http://stackoverflow.com/q/36536111/2066546
  #
  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').to_i == 0
  rescue Timeout::Error
  end

end