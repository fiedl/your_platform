class App.GoogleMap

  map_div: {}
  map: {}
  markers: []
  bounds: {}
  current_info_window: {}

  constructor: (map_div)->
    @map_div = map_div
    @init_map()
    @init_markers()
    @init_bounds()
    @zoom_map()
    @map_div.data 'GoogleMap', this
    @map_div.data 'map', @map

  profile_fields: ->
    if @map_div.data('profile-fields')
      return @map_div.data('profile-fields')
    else if @map_div.data('selector')
      fields = []
      for entry in $(@map_div.data('selector'))
        if $(entry).data('profile-fields')?
          fields = fields.concat $(entry).data('profile-fields')
      return fields
    else if @map_div.data('datatable')
      datatable = $(@map_div.data('datatable')).DataTable()
      selected_rows = datatable.$('tr', {filter: 'applied'})
      fields = []
      for row in selected_rows
        if $(row).data('profile-fields')?
          fields = fields.concat $(row).data('profile-fields')
      return fields

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
    self = this
    self.markers = []
    for profile_field in self.profile_fields()
      if profile_field.position.lng?
        marker = new google.maps.Marker {
          map: self.map,
          position: profile_field.position,
          title: profile_field.title,
          profileable_title: profile_field.profileable_title
        }
        if self.need_info_window()
          marker.addListener 'click', ->
            self.show_marker_info_window this
        self.markers.push marker

  reload_markers: ->
    marker.setMap(null) for marker in @markers
    @init_markers()

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

  show_marker_info_window: (marker)->
    self = this
    $.ajax({
      type: 'GET',
      url: '/api/v1/search/preview',
      data: {
        query: marker.profileable_title
      },
      success: (result) ->
        if result?
          if self.current_info_window.close?
            self.current_info_window.close()
          self.current_info_window = new google.maps.InfoWindow {
            content: result.body
          }
          self.current_info_window.open(self.map, marker)
    })

  need_info_window: ->
    @map_div.hasClass('with_info_window')

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





