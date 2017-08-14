$(document).on 'click', '.edit_vertical_nav', ->

  # Deactivate edit mode
  if $('#vertical_nav .remove_button').length > 0
    $('#vertical_nav .remove_button').remove()
    $('#vertical_nav .move_handle').remove()

  # Activate edit mode
  else
    $('#vertical_nav li.child').each ->
      remove_button = "
        <a class=\"remove_button\" title=\"#{I18n.t('vertical_nav_remove_button')}\"><span class=\"glyphicon glyphicon-trash\"></span></a>
      "
      move_handle = "
        <a class=\"move_handle\" title=\"#{I18n.t('vertical_nav_move_handle')}\"><span class=\"glyphicon glyphicon-menu-hamburger\"></span></a>
      "
      $(this).prepend(remove_button)
      $(this).prepend(move_handle)
      unless $('#vertical_nav ul.nav').hasClass('sortable')
        $('#vertical_nav ul.nav').addClass('sortable').sortable {
          axis: 'y',
          items: '> li.child',
          handle: 'a.move_handle',
          connectWith: '#vertical_nav ul.nav',
          update: ->
            save_vertical_nav_configuration()
        }

save_vertical_nav_configuration = ->
  nav_configuration = []
  $('#vertical_nav ul.nav > li.child').each (index, elem)->
    nav_configuration.push $(elem).find('a.navable').attr('id')
  $('#vertical_nav ul.nav > li.child a').addClass('being_moved')
      .removeClass('error')
  $.ajax {
    type: 'PUT',
    url: '/api/v1/navables/vertical_nav_configuration',
    data: {
      navable_gid: $('body').data('navable'),
      nav_configuration: nav_configuration
    },
    success: ->
      $('#vertical_nav ul.nav > li.child a').removeClass('being_moved')
    error: ->
      $('#vertical_nav ul.nav > li.child a').addClass('error')
  }

load_vertical_nav_configuration = ->
  nav_configuration = $('#vertical_nav').data('nav-configuration')
  if nav_configuration?
    ul = $('#vertical_nav ul')
    for id in nav_configuration.reverse()
      first_child_li = ul.find('li.child:first')
      li = $("a##{id}").closest('li')
      first_child_li.before(li)

$(document).ready ->
  $('.edit_vertical_nav').remove() if $('#vertical_nav li.child').length == 0
  load_vertical_nav_configuration()


$(document).on 'click', '#vertical_nav .remove_button', ->
  li = $(this).closest('li')
  li.find('.remove_button, .move_handle').remove()
  url = "/structureables/sub_entries/destroy"
  data = {
    object_gid: li.find('a').data('navable-gid'),
    parent_gid: $('body').data('navable')
  }
  li.find('a').addClass('being_removed')
  $.ajax {
    type: 'DELETE',
    url: url,
    data: data,
    success: (result)->
      li.remove()
    error: (jqXHR, textStatus, errorThrown)->
      li.find('a').addClass('error').removeClass('being_removed')
  }
