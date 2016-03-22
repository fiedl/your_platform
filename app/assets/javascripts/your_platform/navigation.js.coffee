$(document).ready ->
  jQuery.fn.replace_navigation = (global_id)->
    $.ajax {
      type: 'GET',
      url: "/api/v1/navigation.json",
      data: {
        navable: global_id
      },
      success: (result)->
        $('#breadcrumb').html(result.breadcrumbs)
        $('#vertical_nav > ul').html(result.vertical_nav)
        $('#horizontal_nav').html(result.horizontal_nav)
    }
  
  
  if $('.reload-navigation').data('navable')
    setTimeout ->
      $(document).replace_navigation $('.reload-navigation').data('navable')
      , 10000