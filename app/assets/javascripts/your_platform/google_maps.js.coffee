class App.GoogleMap

  map_div: {}
  map: {}
  markers: []
  bounds: {}

  constructor: (map_div)->
    @map_div = map_div
    @init_map()
    @init_markers()
    @init_bounds()
    @zoom_map()
    @map_div.data 'GoogleMap', this
    @map_div.data 'map', @map

  profile_fields: ->
    @map_div.data('profile-fields')

  dom_element: ->
    @map_div.get(0)

  init_map: ->
    @map = new google.maps.Map @dom_element(), {
      scrollwheel: true
    }

  init_bounds: ->
    @bounds = new google.maps.LatLngBounds()
    for marker in @markers
      @bounds.extend(marker.position)
    @map.fitBounds(@bounds)

  init_markers: ->
    @markers = []
    for profile_field in @profile_fields()
      if profile_field.position.lng?
        marker = new google.maps.Marker {
          map: @map,
          position: profile_field.position,
          title: profile_field.title
        }
        @markers.push marker

  zoom_map: ->
    self = this
    listener = google.maps.event.addListener @map, "idle", ->
      # http://stackoverflow.com/a/4065006/2066546
      self.map.setZoom(5) if self.map.getZoom() > 5
      google.maps.event.removeListener(listener)

  redraw: ->
    @resize()
    @init_bounds()
    @zoom_map()

  resize: ->
    # http://stackoverflow.com/a/6879644/2066546
    center = @map.getCenter()
    google.maps.event.trigger @map, 'resize'
    @map.setCenter(center)

$(document).ready ->
  App.google_maps = []

  $('.google_maps').each ->
    map = new App.GoogleMap($(this))
    App.google_maps.push map

  # Fix for bootstrap javascript nav tabs:
  $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
    # http://www.bootply.com/102241
    for google_map in App.google_maps
      google_map.redraw()





