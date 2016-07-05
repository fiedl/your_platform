$(document).ready ->
  if user_can_manage_home_page()
    nav_ul().sortable {
      update: -> save_horizontal_nav_order()
    }

nav_ul = ->
  $('#horizontal-nav-bar > ul')

update_url = ->
  nav_ul().data('breadcrumb-root-path')

user_can_manage_home_page = ->
  true if update_url()

save_horizontal_nav_order = ->
  $.ajax {
    type: 'PUT',
    url: update_url(),
    data: {
      page: {
        settings: {
          horizontal_nav_page_id_order: current_horizontal_nav_page_id_order()
        }
      }
    }
  }

current_horizontal_nav_page_id_order = ->
  ids = []
  nav_ul().find('> li > a').each (index, elem)->
    ids.push $(elem).data('page-id')
  return ids