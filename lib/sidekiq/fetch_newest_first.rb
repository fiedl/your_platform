require 'sidekiq'
require 'sidekiq/fetch'

module Sidekiq

  # This sidekiq fetcher fetches the left-most, i.e. newest job
  # first.
  #
  # ## How to?
  # http://rockyj.in/2014/02/16/custom_sidekiq_fetcher.html
  #
  # ## Why?
  # The background jobs are mostly used to renew caches. We submit a
  # timestamp that allows to compare whether the cache has already
  # been renewed later than requested. If the jobs are processed in
  # the regular order, we cache the same value twice for subsequent
  # changes.
  #
  class FetchNewestFirst < Sidekiq::BasicFetch

    def retrieve_work
      work = Sidekiq.redis { |conn| conn.blpop(*queues_cmd) }
      UnitOfWork.new(*work) if work
    end

  end
end