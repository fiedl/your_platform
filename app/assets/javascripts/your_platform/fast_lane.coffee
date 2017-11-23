$(document).ready ->

  if $('body').hasClass('fast-lane')
    $.get '/api/v1/current_role', {object_gid: $('body').data('navable')}, (current_role)->
      if current_role['officer?']
        separator = "?"
        separator = "&" if window.location.href.indexOf("?") > -1
        url_without_fast_lane = window.location + separator + "no_fast_lane=true"
        $('#flash_area').prepend("
          <div class='alert alert-info fast_lane'>
            #{I18n.t('you_can_edit_this_page')}
            <a href='#{url_without_fast_lane}' id='load_editable_page_version'>
              #{I18n.t('load_editable_version')}
            </a>
          </div>
        ")

  else if window.location.href.indexOf('no_fast_lane') > -1
    history.pushState(null, null, window.location.href.replace('?no_fast_lane=true', '').replace('&no_fast_lane=true', ''))


