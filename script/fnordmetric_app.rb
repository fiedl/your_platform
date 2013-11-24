require 'fnordmetric'

FnordMetric.namespace :wingolfsplattform do
  
  toplist_gauge :popular_pages, title: "Popular Pages"
  event :show_page do
    observe :popular_pages, data[:title]
  end

  toplist_gauge :popular_groups, title: "Popular Groups"
  event :show_group do
    observe :popular_groups, data[:name]
  end

  toplist_gauge :popular_user_profiles, title: "Popular User Profiles"
  event :show_user do
    observe :popular_user_profiles, data[:title]
  end

  toplist_gauge :popular_search_queries, title: "Popular Search Queries"
  event :search do
    observe :popular_search_queries, data[:query]
  end
  
  toplist_gauge :pupular_request_types, title: "Popular Request Types"
  event :generic_request do
    observe :pupular_request_types, data[:request_type]
  end
  
  widget 'TechStats', {
    :title => "Events per Hour",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_hour,
    :include_current => true,
    :autoupdate => 30
  }
  widget 'TechStats', {
    :title => "Events/Second",
    :type => :timeline,
    :width => 50,
    :gauges => :events_per_second,
    :include_current => true,
    :plot_style => :areaspline,
    :autoupdate => 1
  }
  widget 'TechStats', {
    :title => "Events Numbers",
    :type => :numbers,
    :width => 100,
    :gauges => [:events_per_second, :events_per_minute, :events_per_hour],
    :offsets => [1,3,5,10],
    :autoupdate => 1
  }
  gauge :events_per_hour, :tick => 1.hour
  gauge :events_per_second, :tick => 1.second
  gauge :events_per_minute, :tick => 1.minute
  event :"*" do
    incr :events_per_hour
    incr :events_per_minute
    incr :events_per_second
  end
  
end

FnordMetric::Web.new(port: 4242)
FnordMetric::Worker.new
FnordMetric.run

