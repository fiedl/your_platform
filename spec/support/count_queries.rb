require 'colored'
module CountQueries
  
  # This counts the number of queries performed within the block.
  #
  # Usage:
  #
  #     c = count_queries do
  #       SomeModel.first
  #     end
  #
  # See also: http://stackoverflow.com/a/22388177/2066546
  #
  def count_queries(expected_count = nil, &block)
    queries = collect_queries(&block)
    
    # Output the queries if the count does not match.
    if expected_count && queries.count != expected_count
      queries.each do |query|
        print query.yellow + "\n\n"
      end
    end
    
    return queries.count
  end
  
  def collect_queries(&block)
    queries = []
    
    counter_f = ->(name, started, finished, unique_id, payload) {
      unless payload[:name].in? %w[ CACHE SCHEMA ]
        queries << payload[:sql]
      end
    }

    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)

    return queries
  end
  
end