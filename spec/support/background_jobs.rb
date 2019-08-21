module BackgroundJobs

  def run_background_jobs
    Sidekiq::Worker.drain_all
  end

end