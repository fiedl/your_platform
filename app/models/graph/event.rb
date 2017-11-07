class Graph::Event < Graph::Node

  def event
    @object
  end

  # # This causes "end of file reached (EOFError)"
  # # in specs, e.g. in rspec ./spec/features/events_spec.rb:350
  #def sync
  #  super
  #  Graph::HasEvent.sync event if event.group
  #end

  def node_label
    "Event"
  end

  def properties
    {id: event.id, title: event.title.to_s, start_at: event.start_at.to_s}
  end

end