module WaitForAjax
  
  def wait_for_ajax
    sleep(wait_time)
  end
  
  def wait_time
    @wait_time ||= wait_time_from_benchmark
  end
  
  def wait_time_from_benchmark
    n = 3000000  # which corresponds roughly to 1 second locally for my system.
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
  
end