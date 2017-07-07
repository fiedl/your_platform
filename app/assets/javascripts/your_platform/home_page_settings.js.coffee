$(document).on 'click', '.home_page_settings .show_in_menu label', ->
  $('#horizontal_nav').html("...")
  url = "/api/v1/navigation.json"
  setTimeout ->
    $.ajax {
      type: 'GET',
      url: url,
      data: {
        navable: $('body').data('navable'),
        uncached: true
      },
      success: (result)->
        $('#horizontal_nav').html $(result['horizontal_nav']).html()
    }
  , 300

